import 'dart:async';

import 'package:octo360/application/enum/battery_connection_status.dart';
import 'package:octo360/application/enum/device_status_enum.dart';
import 'package:octo360/application/enum/electrodes_status_enum.dart';
import 'package:octo360/application/utils/lcoal_notification_utils/local_notification_utils.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/factory_manager.dart';
import 'package:octo360/data/local/bridge/scanner/ble_scanner_plugin.dart';
import 'package:octo360/data/local/notification/local_notification_modal/local_notification_modal.dart';
import 'package:octo360/data/local/notification/local_notification_services.dart';
import 'package:octo360/data/model/failure.dart';
import 'package:octo360/data/model/graphql/model/ecg0_device/ecg0_device.dart';
import 'package:octo360/data/model/graphql/request/ecg0_study_by_patient_info_filter/ecg0_study_by_patient_info_filter.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/data/remote/graphql/exceptions/graphql_exception_handler.dart';
import 'package:octo360/data/remote/socketio/octobeat/socket_octobeat_device_handler.dart';
import 'package:octo360/data/remote/socketio/socketio_client.dart';
import 'package:octo360/domain/bloc/base/base_cubit.dart';
import 'package:octo360/domain/bloc/global_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/domain/model/device/octobeat_device_domain.dart';
import 'package:octo360/domain/model/global/global_state.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_study_view_state.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_data.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_plugin.dart';
import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_device.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

class OctoBeatStudyViewBloc extends BaseCubit<OctoBeatStudyViewState> {
  OctoBeatStudyViewBloc() : super(OctoBeatStudyViewState());
  StreamSubscription? _globalReloadListener;
  StreamSubscription<OctoBeatData?>? _localDeviceEventsListener;
  StreamSubscription<BluetoothState?>? _bluetoothOnOffListener;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  StreamSubscription<SocketData>? _socketSubscription;
  bool isInited = false;
  bool isInitedBluetoothListener = false;

  StreamSubscription<OctoBeatConnectionData?>? connectDeviceListener;

  void initState(BuildContext context) {
    _setupBluetoothListener();
    _initData();
    _setupGlobalReloadListener(context);
    _subscribeConnectivityStream();
    _checkFromNotification(context);
  }

  @override
  Future<void> close() {
    _globalReloadListener?.cancel();
    _localDeviceEventsListener?.cancel();
    _bluetoothOnOffListener?.cancel();
    _connectivitySub?.cancel();
    _socketSubscription?.cancel();
    return super.close();
  }

  void _initData() async {
    final globalRepo = FactoryManager.provideGlobalRepo();
    final patientId = globalRepo.userDomain?.id ?? '';
    final phoneNumber = globalRepo.userDomain?.contactInfo?.phoneNumber ?? '';
    final device = await OctoBeatPlugin.getDeviceInfo();
    _createData(device?.toDomain(null));
    emit(state.copyWith(
      noticeEnum: DevicesStatusEnum.none,
      warningEnum: DevicesStatusEnum.none,
      phone: phoneNumber,
      patientId: patientId,
    ));
    _getData();
    _initSocket();
    _setupLocalDeviceEventsListener();
  }

  void _initSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = FactoryManager.provideSocketOctoBeatDevice()
        .listenEvents()
        ?.listen((event) {
      final type = OctoBeatDeviceEvent.from(event.event);
      switch (type) {
        case OctoBeatDeviceEvent.studyEvent:
          final study = ECG0StudyByPatientInfo.fromJson(event.data);
          _updateStudyInfoBySocket(study);
          break;
        case OctoBeatDeviceEvent.deviceEvent:
          final device = ECG0Device.fromJson(event.data);
          print('OctoBeatDeviceEvent.deviceEvent $device');
          // _updateStudyInfoBySocket(study);
          break;
        default:
      }
    });
  }

  void _updateStudyInfoBySocket(ECG0StudyByPatientInfo study) async {
    final device = await OctoBeatPlugin.getDeviceInfo();
    final octoBeatDevice = device?.toDomain(study);
    _createData(octoBeatDevice);
  }

  void _setupLocalDeviceEventsListener() {
    _localDeviceEventsListener?.cancel();
    _localDeviceEventsListener = OctoBeatPlugin.listenEvent().listen((event) {
      switch (event.event) {
        case OctoBeatEvent.updateInfo:
          final deviceInfo = event.toOctoBeatDevice();
          if (deviceInfo != null) {
            _updateInfo(deviceInfo);
          }
          break;
        default:
      }
    });
  }

  void _updateInfo(OctoBeatDevice? deviceInfo) async {
    //setting up -> in progress -> call API to get stop study time
    if (state.octobeatDevice?.studyStatus == OctoBeatStudyStatus.setting &&
        deviceInfo?.studyStatus == OctoBeatStudyStatus.studyProgress &&
        state.screenState != OctoBeatViewState.noInternet) {
      _getData();
      return;
    }
    //completed
    if (deviceInfo?.studyStatus == OctoBeatStudyStatus.ready) {
      _localDeviceEventsListener?.cancel();
      _onStudyDone();
      return;
    }

    final device = state.octobeatDevice?.updateInfo(deviceInfo!);

    _createData(device);
  }

  ///Show notice when have difference error or over 5 minutes
  bool _canShowNotice(DevicesStatusEnum status) {
    return status != DevicesStatusEnum.none &&
        (state.lastNoticeHide == null ||
            status != state.lastNoticeHide ||
            DateTime.now()
                    .difference(state.lastTimeHideNotice ?? DateTime.now())
                    .inMinutes >
                5);
  }

  Future<ECG0StudyByPatientInfo?> _queryOctoBeatStudy() async {
    final graphqlRepo = FactoryManager.provideGraphQlOctoBeatRepo();
    final study = await graphqlRepo.getStudyByPatientInfo(
        filter: ECG00StudyByPatientInfoFilter(
      patientId: state.patientId,
      phone: state.phone,
    ));
    return study;
  }

  void _handleError(Failure error) async {
    final device = await OctoBeatPlugin.getDeviceInfo();
    if (error.code == GraphQLResponseCode.NO_INTERNET_CONNECTION) {
      emit(state.copyWith(
        screenState: OctoBeatViewState.noInternet,
        warningEnum: DevicesStatusEnum.none,
        noticeEnum: DevicesStatusEnum.none,
        device:
            device != null ? state.octobeatDevice?.updateInfo(device) : null,
      ));
      return;
    }
    Log.e(error.message);
    emit(
      state.copyWith(
        screenState: OctoBeatViewState.failed,
        device:
            device != null ? state.octobeatDevice?.updateInfo(device) : null,
      ),
    );
  }

  Future<void> _onStudyDone() async {
    _socketSubscription?.cancel();
    _globalReloadListener?.cancel();
    _localDeviceEventsListener?.cancel();
    _bluetoothOnOffListener?.cancel();

    await OctoBeatConnectionPlugin.deleteDevice();

    emit(state.copyWith(screenState: OctoBeatViewState.studyCompleted));
  }

  void _setupBluetoothListener() {
    _bluetoothOnOffListener?.cancel();
    _bluetoothOnOffListener = BleScannerPlugin.listenEvent().listen((event) {
      switch (event) {
        case BluetoothState.on:
          if (isInitedBluetoothListener) {
            _getData();
          }
          isInitedBluetoothListener = true;
          break;
        case BluetoothState.off:
          emit(state.copyWith(warningEnum: DevicesStatusEnum.bluetoothTurnOff));
          break;
        default:
          break;
      }
    });
  }

  void _setupGlobalReloadListener(BuildContext context) {
    _globalReloadListener?.cancel();
    _globalReloadListener =
        context.read<GlobalBloc>().listenGlobalChanges().listen((event) {
      if (event.reloadState == ReloadState.reloadOctoBeatDevice) {
        _reloadState(event.forceReload, event.reloadParams);
      }
    });
  }

  void _reloadState(bool forceReload, dynamic reloadParams) {
    if (forceReload) {
      _initData();
    } else {
      try {
        final device = reloadParams as OctobeatDeviceDomain;
        _createData(device);
      } catch (e) {
        Log.e(e);
      }
    }
  }

  void _onUpdateInternetConnect(bool isConnected) {
    if (isConnected) {
      _initData();
    } else {
      emit(state.copyWith(
        screenState: OctoBeatViewState.noInternet,
        warningEnum: state.warningEnum != DevicesStatusEnum.bluetoothTurnOff
            ? DevicesStatusEnum.none
            : null,
        noticeEnum: DevicesStatusEnum.none,
      ));
    }
  }

  Future<void> _getData() async {
    try {
      final study = await _queryOctoBeatStudy();
      _handleStudyStatus(study);
    } on Failure catch (error) {
      _handleError(error);
    }
  }

  void _handleStudyStatus(ECG0StudyByPatientInfo? study) async {
    final device = await OctoBeatPlugin.getDeviceInfo();
    switch (study?.status) {
      case "Done":
        // in case re-open app and study completed -> check Holter & Follow on Study
        if (state.octobeatDevice == null &&
            state.previousStudyStatus == null &&
            state.screenState == OctoBeatViewState.loading) {
          _createData(device?.toDomain(null));
          _onStudyDone();
          return;
        }
        //Don't have new study
        await _onStudyDone();
        break;
      default:
        final octoBeatDevice = device?.toDomain(study);
        _createData(octoBeatDevice);
    }
  }

  ///check errors of device and study
  ///return List<DevicesStatusEnum>, with first element if noticeEnum,
  ///and second value is warning enum
  Future<List<DevicesStatusEnum>> checkErrors(
      OctobeatDeviceDomain device) async {
    DevicesStatusEnum noticeEnum = DevicesStatusEnum.none;
    DevicesStatusEnum warningEnum = DevicesStatusEnum.none;

    if (!(await BleScannerPlugin.isBleEnable())) {
      return [DevicesStatusEnum.none, DevicesStatusEnum.bluetoothTurnOff];
    }

    if (device.studyStatus == OctoBeatStudyStatus.studyProgress ||
        device.studyStatus == OctoBeatStudyStatus.studyPaused) {
      if (!device.isConnected) {
        noticeEnum = DevicesStatusEnum.disconnectNotice;
      } else {
        //Device offline
        if (!device.isDeviceOnline) {
          final lastSync = DateTime.now()
              .difference(device.latSyncTime ?? DateTime.now())
              .inMinutes;
          //device offline under/over 2 hours
          if (lastSync < 120) {
            noticeEnum = DevicesStatusEnum.offlineNotice;
          } else {
            warningEnum = DevicesStatusEnum.offlineTroubleshoot;
          }
        } else {
          if (device.batteryStatus == BatteryConnectionStatus.low) {
            //low battery
            warningEnum = DevicesStatusEnum.lowbatterryTroubleshoot;
          } else if (device.electrodesConnectionStatus ==
              ElectrodesStatus.disconnected) {
            final lastSync = DateTime.now()
                .difference(device.lastLeadDisconnectedAt ?? DateTime.now())
                .inMinutes;
            //electrodes disconnect under/over 2 hours
            if (lastSync < 120) {
              noticeEnum = DevicesStatusEnum.cableLooseNotice;
            } else {
              warningEnum = DevicesStatusEnum.disconnectTroubleshoot;
            }
          }
        }
      }
    }

    return [noticeEnum, warningEnum];
  }

  void _createData(OctobeatDeviceDomain? device) async {
    if (device == null) {
      emit(state.copyWith(
        screenState: OctoBeatViewState.success,
        warningEnum: DevicesStatusEnum.none,
        noticeEnum: DevicesStatusEnum.none,
      ));
      return;
    }

    var screenState = OctoBeatViewState.success;

    final errors = await checkErrors(device);
    final hasNotice = errors[0] != DevicesStatusEnum.none;
    emit(state.copyWith(
      previousStudyStatus: state.octobeatDevice?.studyStatus,
      device: device,
      screenState: screenState,
      noticeEnum: _canShowNotice(errors[0])
          ? errors[0]
          : !hasNotice
              ? errors[0]
              : null,
      warningEnum: errors[1],
      //when dont have error, reset last time and item error
      lastNoticeHide: !hasNotice ? null : state.lastNoticeHide,
      lastTimeHideNotice: !hasNotice ? null : state.lastTimeHideNotice,
    ));
  }

  void setShowIndicator(bool isShow) {
    if (isShow != state.isShowIndicator) {
      emit(state.copyWith(isShowIndicator: isShow));
    }
  }

  void onHideNotice() {
    emit(
      state.copyWith(
        noticeEnum: DevicesStatusEnum.none,
        lastNoticeHide: state.noticeEnum,
        lastTimeHideNotice: DateTime.now(),
      ),
    );
  }

  Future<void> _onClearState() async {
    await OctoBeatConnectionPlugin.deleteDevice();

    final tempState = state.copyWith();
    tempState.previousStudyStatus = null;
    tempState.screenState = OctoBeatViewState.disconnect;
    tempState.octobeatDevice = null;
    emit(tempState);
  }

  Future<void> removeDevice() async {
    emit(state.copyWith(
        screenState: OctoBeatViewState.loading, isShowIndicator: false));
    try {
      await _onClearState();
      emit(state.copyWith(screenState: OctoBeatViewState.removed));
    } catch (error) {
      if (error is Failure &&
          error.code == GraphQLResponseCode.NO_INTERNET_CONNECTION) {
        emit(state.copyWith(
          screenState: OctoBeatViewState.noInternet,
          warningEnum: DevicesStatusEnum.none,
          noticeEnum: DevicesStatusEnum.none,
        ));
        return;
      }

      emit(state.copyWith(screenState: OctoBeatViewState.failed));
    }
  }

  void onPressTryAgain() {
    _initData();
  }

  void _subscribeConnectivityStream() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (isInited) {
        if (result == ConnectivityResult.none) {
          _onUpdateInternetConnect(false);
        } else {
          _onUpdateInternetConnect(true);
        }
      }
      isInited = true;
    });
  }

  void _checkFromNotification(context) {
    LocalNotificationServices.selectNotificationStream.stream
        .listen((FromNotification fromNotification) async {
      LocalNotificationUtils.handleNotificationNavigation(context);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationUtils.handleNotificationNavigation(context);
    });
  }
}
