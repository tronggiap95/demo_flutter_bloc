import 'dart:async';
import 'dart:io';

import 'package:octo360/application/enum/dialog_state_enum.dart';
import 'package:octo360/application/enum/octobeat_timeout_enum.dart';
import 'package:octo360/application/enum/pairing_state.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/application/utils/permission/permission_utils.dart';
import 'package:octo360/data/local/bridge/scanner/ble_scanner_plugin.dart';
import 'package:octo360/data/service/location/localtion_service.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_pair_device_state.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_data.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_event.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_plugin.dart';
import 'package:octo_beat_plugin/connection/octo_beat_scan_result.dart';
import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

class OctobeatPairDeviceBloc extends BaseCubit<OctobeatPairDeviceState> {
  OctobeatPairDeviceBloc() : super(OctobeatPairDeviceState());

  // final GraphqlOctoRepo _repo;

  /// Not jump event when first init.
  /// when resume bluetooth listener
  /// bluetooth listener will jump event
  StreamSubscription<BluetoothState?>? bluetoothOnOffListener;
  Timer? _timeout;

  bool isBluetoothPermissionChecked = false;
  bool isLocationPermissionChecked = false;

  StreamSubscription<OctoBeatConnectionData?>? connectDeviceListener;
  StreamSubscription<OctoBeatData?>? coreListener;

  void initState(String? deviceId) {
    emit(state.copyWith(deviceId: deviceId));
    _setupScanListener();
    _setupCoreListener();
    _setupBluetoothListener();
    handleStep(PairingState.checkPermission);
  }

  void _setupScanListener() async {
    connectDeviceListener =
        OctoBeatConnectionPlugin.listenEvent().listen((event) {
      Log.d("_setupScanListener: event: ${event?.event}, data: ${event?.data}");
      if (event == null) return;
      switch (event.event) {
        case OctoBeatConnectionEvent.foundDevice:
          _handleFoundDevice(event);
          break;
        case OctoBeatConnectionEvent.connectSuccess:
          _handleConnectSuccess(event);
          break;
        case OctoBeatConnectionEvent.connectFailed:
          _handleConnectFailed();
          break;
        default:
          break;
      }
    });
  }

  void _handleConnectFailed() {
    _handleDialogState(DialogState.pairingFailed);
  }

  void _handleFoundDevice(OctoBeatConnectionData event) {
    final listScanResult = event.toScanResults();
    for (OctoBeatScanResult device in listScanResult) {
      if (state.deviceId == device.name) {
        state.deviceId = device.name;
        state.deviceAddress = device.address;
        _stopScan();
        handleStep(PairingState.pairing);
        break;
      }
    }
  }

  void _handleConnectSuccess(OctoBeatConnectionData event) async {
    clearTimer();
    handleStep(PairingState.connected);
  }

  void _setupCoreListener() {
    coreListener = OctoBeatPlugin.listenEvent().listen((event) {
      switch (event.event) {
        case OctoBeatEvent.updateInfo:
          _handleUpdateInfo(event);
          break;
        default:
          break;
      }
    });
  }

  void _handleUpdateInfo(OctoBeatData event) {
    final device = event.toOctoBeatDevice();

    // Handle case: MCT Study with study status: 'Draft'
    if (device?.studyStatus == OctoBeatStudyStatus.setting) {
      handleStep(PairingState.success);
    }
  }

  void _setupBluetoothListener() {
    cancelBluetoothListener();
    bluetoothOnOffListener = BleScannerPlugin.listenEvent().listen((event) {
      switch (event) {
        case BluetoothState.on:
          resetDialog();
          handleStep(PairingState.checkBluetooth);
          break;
        case BluetoothState.off:
          if (state.pairingState != PairingState.connected) {
            _handleDialogState(DialogState.bluetoothNotAvailable);
          }
          break;
        default:
          break;
      }
    });
  }

  void handleStep(PairingState pairingState) async {
    switch (pairingState) {
      case PairingState.checkPermission:
        final temp = state.copyWith(
          pairingState: PairingState.checkPermission,
          dialogState: DialogState.none,
        );
        temp.deviceId = null;
        temp.deviceAddress = null;

        emit(temp);
        handlePermission();
        break;
      case PairingState.checkBluetooth:
        emit(state.copyWith(pairingState: PairingState.checkBluetooth));
        checkBluetoothState();
        break;
      case PairingState.checkLocation:
        state.pairingState = PairingState.checkLocation;
        bool serviceEnabled = await LocationService.isEnableForScanningBLe();
        if (!serviceEnabled) {
          clearTimer();
          serviceEnabled = await LocationService.requestLocation();
          if (serviceEnabled) {
            handleStep(PairingState.scanning);
          } else {
            // no location go to get Start
            _handleDialogState(DialogState.locationNotAvailable);
          }
        } else {
          handleStep(PairingState.scanning);
        }
        break;
      case PairingState.scanning:
        emit(state.copyWith(pairingState: PairingState.scanning));

        _scanningDevice();
        break;
      case PairingState.scanned:
        //has done in handle dialog state
        break;
      case PairingState.deviceNotFound:
        emit(state.copyWith(pairingState: PairingState.deviceNotFound));
        break;
      case PairingState.pairing:
        clearTimer();
        state.pairingState = PairingState.pairing;
        _handleDialogState(DialogState.pairingDevice);
        _pairingDevice();
        break;
      case PairingState.connected:
        state.pairingState = PairingState.connected;
        _handleStatusAfterConnected();
        break;
      case PairingState.success:
        await _handlePairingSuccess();
        break;
      default:
        break;
    }
  }

  Future<void> _handlePairingSuccess() async {
    try {
      state.pairingState = PairingState.success;
      _handleDialogState(DialogState.connectSuccess);
    } catch (e) {
      Log.e("error: $e");
      _handleDialogState(DialogState.somethingWentWrong);
    }
  }

  void _scanningDevice() async {
    _startTimer(
        OctobeatTimeout.scanningTimeOut.getValue, _handleScanningFailed);
    _startScan();
  }

  void _pairingDevice() async {
    _startTimer(OctobeatTimeout.pairingTimeOut.getValue, () {
      _handleDialogState(DialogState.pairingFailed);
    });
    _connectDevice();
  }

  void _handleScanningFailed() async {
    handleStep(PairingState.deviceNotFound);
    await OctoBeatConnectionPlugin.stopScan();
    clearTimer();
  }

  void checkBluetoothState() async {
    final isBluetoothEnable = await BleScannerPlugin.isBleEnable();
    if (isBluetoothEnable) {
      handleStep(PairingState.checkLocation);
    } else {
      _handleDialogState(DialogState.bluetoothNotAvailable);
    }

    if (bluetoothOnOffListener != null) {
      bluetoothOnOffListener?.resume();
    }
  }

  void handlePermission() async {
    final scanPermission = await PermissionUtils.checkScanPermission();
    switch (scanPermission) {
      case ScanStateEnum.granted:
        handleStep(PairingState.checkBluetooth);
        break;
      case ScanStateEnum.bluetoothDenied:
        if (Platform.isIOS) {
          _handleDialogState(DialogState.requireBluetoothPermission);
          return;
        }
        if (!isBluetoothPermissionChecked) {
          PermissionUtils.requestBluetoothPermission();
          isBluetoothPermissionChecked = true;
          return;
        }
        _handleDialogState(DialogState.requireBluetoothPermission);
        break;
      case ScanStateEnum.bluetoothPermanentlyDenied:
        if (Platform.isIOS) {
          _handleDialogState(DialogState.requireBluetoothPermission);
          return;
        }
        if (!isBluetoothPermissionChecked) {
          PermissionUtils.requestBluetoothPermission();
          isBluetoothPermissionChecked = true;
          return;
        }
        _handleDialogState(DialogState.requireBluetoothPermission);
        break;
      case ScanStateEnum.locationDenied:
        if (!isLocationPermissionChecked) {
          PermissionUtils.requestLocationPermission();
          isLocationPermissionChecked = true;
          return;
        }
        _handleDialogState(DialogState.requireLocationPermission);
        break;
      case ScanStateEnum.locationPermanentlyDenied:
        if (!isLocationPermissionChecked) {
          PermissionUtils.requestLocationPermission();
          isLocationPermissionChecked = true;
          return;
        }
        _handleDialogState(DialogState.requireLocationPermission);
        break;
    }
  }

  void _handleDialogState(DialogState dialogState) async {
    switch (dialogState) {
      case DialogState.requireBluetoothPermission:
        emit(state.copyWith(
            dialogState: DialogState.requireBluetoothPermission));
        break;
      case DialogState.requireLocationPermission:
        emit(
            state.copyWith(dialogState: DialogState.requireLocationPermission));
        break;
      case DialogState.bluetoothNotAvailable:
        _stopScan();
        clearTimer();
        final temp = state.copyWith(
            dialogState: DialogState.bluetoothNotAvailable,
            pairingState: PairingState.checkBluetooth);

        emit(temp);
        break;
      case DialogState.locationNotAvailable:
        emit(state.copyWith(dialogState: DialogState.locationNotAvailable));
        break;
      case DialogState.pairingFailed:
        clearTimer();
        _disconnectDevice();
        final temp = state.copyWith(dialogState: DialogState.pairingFailed);
        emit(temp);
        break;
      case DialogState.somethingWentWrong:
        await OctoBeatConnectionPlugin.deleteDevice();
        emit(state.copyWith(dialogState: DialogState.somethingWentWrong));
        break;

      case DialogState.pairingDevice:
        emit(state.copyWith(dialogState: DialogState.pairingDevice));
        break;

      case DialogState.connectSuccess:
        emit(state.copyWith(dialogState: DialogState.connectSuccess));
        break;
      case DialogState.failedToStartStudy:
        emit(state.copyWith(dialogState: DialogState.failedToStartStudy));
        OctoBeatConnectionPlugin.deleteDevice();
        break;
      default:
        break;
    }
  }

  void _handleStatusAfterConnected() {
    handleStep(PairingState.success);
  }

  void resetDialog() {
    state.dialogState = DialogState.none;
  }

  void _stopScan() async {
    await OctoBeatConnectionPlugin.stopScan();
  }

  void _startScan() async {
    await OctoBeatConnectionPlugin.startScan();
  }

  void _connectDevice() async {
    await OctoBeatConnectionPlugin.connect(state.deviceAddress!);
  }

  void _disconnectDevice() async {
    await OctoBeatConnectionPlugin.deleteDevice();
  }

  void _cancelListenerAndTimer() {
    clearTimer();
    connectDeviceListener?.cancel();
    coreListener?.cancel();
  }

  void cancelBluetoothListener() {
    bluetoothOnOffListener?.pause();
  }

  void restartBluetoothListener() {
    if (bluetoothOnOffListener?.isPaused ?? false) {
      bluetoothOnOffListener?.resume();
    }
  }

  void _startTimer(int timeInSecond, Function() callback) {
    clearTimer();
    _timeout = Timer(Duration(seconds: timeInSecond), callback);
  }

  void clearTimer() {
    _timeout?.cancel();
  }

  @override
  Future<void> close() {
    _stopScan();
    _cancelListenerAndTimer();
    cancelBluetoothListener();
    return super.close();
  }
}
