import 'package:app_settings/app_settings.dart';
import 'package:octo360/application/enum/dialog_state_enum.dart';
import 'package:octo360/application/enum/octobeat_timeout_enum.dart';
import 'package:octo360/application/enum/pairing_state.dart';
import 'package:octo360/data/local/bridge/package/package_manager_plugin.dart';
import 'package:octo360/data/service/location/localtion_service.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_pair_device_bloc.dart';

import 'package:octo360/domain/model/home/octobeat/octobeat_pair_device_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:octo360/presentation/widgets/app_bar/custom_app_bar/custom_app_bar.dart';
import 'package:octo360/presentation/widgets/dialog/connect_device_successfully_dialog/connect_device_successfully_dialog.dart';
import 'package:octo360/presentation/widgets/dialog/custom_dialog/custom_dialog.dart';
import 'package:octo360/presentation/widgets/dialog/octobeat_connecting_device_dialog/octobeat_connecting_device_dialog.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctobeatPairDeviceScreen extends StatefulWidget {
  const OctobeatPairDeviceScreen({required this.deviceId, Key? key})
      : super(key: key);
  final String deviceId;
  @override
  State<OctobeatPairDeviceScreen> createState() =>
      _OctobeatPairDeviceScreenState();
}

class _OctobeatPairDeviceScreenState extends State<OctobeatPairDeviceScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<OctobeatPairDeviceBloc>().initState(widget.deviceId);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        context.read<OctobeatPairDeviceBloc>().restartBluetoothListener();
        _handleResumedState();
        break;
      case AppLifecycleState.paused:
        context.read<OctobeatPairDeviceBloc>().cancelBluetoothListener();
        break;
      default:
        break;
    }
  }

  _handleResumedState() async {
    final pairingState =
        context.read<OctobeatPairDeviceBloc>().state.pairingState;
    switch (pairingState) {
      case PairingState.checkLocation:
        bool serviceEnabled = await LocationService.isEnable();
        if (!serviceEnabled) {
          _gotoRefCodeScreen();
        }
        break;
      case PairingState.checkPermission:
      case PairingState.scanning:
        Future.delayed(Duration.zero, () {
          NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
          context.read<OctobeatPairDeviceBloc>().handlePermission();
        });

        break;
      case PairingState.checkBluetooth:
        Future.delayed(Duration.zero, () {
          NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
          context.read<OctobeatPairDeviceBloc>().checkBluetoothState();
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(context),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: MarginApp.m16),
        width: double.infinity,
        child: BlocListener<OctobeatPairDeviceBloc, OctobeatPairDeviceState>(
          listener: (context, state) {
            _handleDialogListener(state.dialogState);
            //handle connect successful
            if (state.pairingState == PairingState.success) {
              _handleConnectSuccessful();
            }
          },
          child: BlocBuilder<OctobeatPairDeviceBloc, OctobeatPairDeviceState>(
            builder: (context, state) {
              switch (state.pairingState) {
                case PairingState.deviceNotFound:
                  return _renderNoDeviceFound();
                case PairingState.scanning:
                  return _renderScanningDevice();
                default:
                  return _renderScanningDevice(deviceFound: true);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _renderNoDeviceFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: MarginApp.m64),
              height: 160,
              width: 160,
              child: SvgPicture.asset(
                ImagesApp.bluetoothStopped,
              ),
            ),
            const SizedBox(height: MarginApp.m64),
            Column(
              children: [
                Text(StringsApp.deviceNotFound,
                    style: TextStylesApp.bold(
                        color: ColorsApp.coalDarker,
                        fontSize: FontSizeApp.s18)),
                const SizedBox(height: MarginApp.m26),
                Text(
                  StringsApp.makeSureDeviceDiscoverableOctobeat,
                  textAlign: TextAlign.center,
                  style: TextStylesApp.regular(
                    color: ColorsApp.coalDarker,
                    fontSize: FontSizeApp.s14,
                  ),
                ),
              ],
            ),
          ],
        ),
        _renderButton(),
      ],
    );
  }

  Widget _renderScanningDevice({
    bool deviceFound = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: MarginApp.m24),
        Stack(
          alignment: Alignment.center,
          children: [
            deviceFound
                ? const SizedBox.shrink()
                : SizedBox(
                    width: 240,
                    height: 240,
                    child: Lottie.asset(
                      ImagesApp.circleBluetooth,
                      frameRate: FrameRate.max,
                      fit: BoxFit.fill,
                    ),
                  ),
            Container(
              height: 240,
              width: 240,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: ColorsApp.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  ImagesApp.icBluetooth,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: MarginApp.m32),
        deviceFound
            ? const SizedBox.shrink()
            : Column(
                children: [
                  Text(
                    StringsApp.scanningForDevice,
                    style: TextStylesApp.bold(
                      color: ColorsApp.coalDarker,
                      fontSize: FontSizeApp.s18,
                    ),
                  ),
                  const SizedBox(height: MarginApp.m26),
                  Text(
                    StringsApp.makeSureDeviceDiscoverableOctobeat,
                    textAlign: TextAlign.center,
                    style: TextStylesApp.regular(
                      color: ColorsApp.coalDarker,
                      fontSize: FontSizeApp.s14,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  _handleDialogListener(DialogState? dialogState) {
    NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);

    switch (dialogState) {
      case DialogState.requireBluetoothPermission:
        _showBluetoothPermissionDialog();
        break;
      case DialogState.requireLocationPermission:
        _showLocationPermissionDialog();
        break;
      case DialogState.bluetoothNotAvailable:
        NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
        _showBluetoothUnavailableDialog();
        break;
      case DialogState.locationNotAvailable:
        break;
      case DialogState.pairingDevice:
        _showPairingDialog();
        break;
      case DialogState.pairingFailed:
        NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
        _showPairingFailedDialog();
        break;
      case DialogState.somethingWentWrong:
        _showPairingFailedDialog();
        break;
      case DialogState.connectSuccess:
        NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
        _showPairSuccessDialog();
        break;
      case DialogState.failedToStartStudy:
        NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
        _showFailedToStartStudyDialog();
        break;
      default:
        break;
    }
  }

  void _handleConnectSuccessful() async {
    Future.delayed(
        Duration(seconds: OctobeatTimeout.connectSuccessfullyDelay.getValue),
        () {
      NavigationApp.pop(context);
      NavigationApp.pop(context);
    });
  }

  void _showFailedToStartStudyDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              isErrorDialog: false,
              imagePath: ImagesApp.failed,
              title: StringsApp.failedToStartStudy,
              message: StringsApp.pleaseTryConnecting,
              neutralButtonText: StringsApp.okay,
              hasBorderNeutralButton: true,
              onPressNeutraltiveButton: () {
                _gotoRefCodeScreen();
              },
            ),
          );
        });
  }

  void _showBluetoothUnavailableDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              isErrorDialog: false,
              imagePath: ImagesApp.attention,
              title: StringsApp.bluetoothIsNotAvailable,
              message: StringsApp.toConnectWithOctobeatDevice,
              positiveButtonText: StringsApp.goToSettings,
              onPressPositiveButton: () {
                PackageManagerPlugin.openBlueSetting();
              },
              negativeButtonText: StringsApp.cancel,
              onPressNegativeButton: () async {
                _gotoRefCodeScreen();
              },
            ),
          );
        });
  }

  void _showBluetoothPermissionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              isErrorDialog: false,
              isTitleCenter: true,
              title: StringsApp.octo360WouldLikeToAccessBluetooth,
              message: StringsApp.pleaseEnableTheBluetooth,
              positiveButtonText: StringsApp.openSettings,
              onPressPositiveButton: () {
                NavigationApp.pop(context);
                AppSettings.openAppSettings();
              },
              negativeButtonText: StringsApp.cancel,
              onPressNegativeButton: () async {
                _gotoRefCodeScreen();
              },
            ),
          );
        });
  }

  void _showLocationPermissionDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              isErrorDialog: false,
              isTitleCenter: true,
              title: StringsApp.octo360WouldLikeToAccessLocation,
              message: StringsApp.pleaseEnableTheLocation,
              positiveButtonText: StringsApp.openSettings,
              onPressPositiveButton: () {
                NavigationApp.pop(context);
                AppSettings.openAppSettings();
              },
              negativeButtonText: StringsApp.cancel,
              onPressNegativeButton: () async {
                _gotoRefCodeScreen();
              },
            ),
          );
        });
  }

  void _showPairingDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            child: const OctobeatConnectingDeviceDialog(),
            onWillPop: () async => false,
          );
        });
  }

  void _showPairSuccessDialog() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return WillPopScope(
            child: ConnectDeviceSuccessfullyDialog(
              headerTitle: StringsApp.connectSuccessfully,
              imagePath: ImagesApp.octoBeatConnectSuccessful,
            ),
            onWillPop: () async => false,
          );
        });
  }

  void _showPairingFailedDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              isErrorDialog: false,
              imagePath: ImagesApp.failed,
              title: StringsApp.failedToConnectDevice,
              message: StringsApp.somethingWentWrongPleaseMakeSure,
              positiveButtonText: StringsApp.tryAgain,
              onPressPositiveButton: () {
                NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
                context
                    .read<OctobeatPairDeviceBloc>()
                    .handleStep(PairingState.checkPermission);
              },
              negativeButtonText: StringsApp.cancel,
              onPressNegativeButton: () async {
                _gotoRefCodeScreen();
              },
            ),
          );
        });
  }

  Widget _renderButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<OctobeatPairDeviceBloc>()
                  .handleStep(PairingState.checkPermission);
            },
            child: Text(StringsApp.tryAgain),
          ),
        ),
        const SizedBox(height: MarginApp.m8),
      ],
    );
  }

  void _gotoRefCodeScreen() {
    NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
    NavigationApp.back(context);
  }

  PreferredSizeWidget _renderAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidget: SvgPicture.asset(
        ImagesApp.icArrowBackAndroid,
        color: ColorsApp.coalDarkest,
        height: SizeApp.s18,
        width: SizeApp.s18,
      ),
      titleWidget: Text(
        StringsApp.connectOctobeatDevice,
        style: TextStylesApp.bold(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s16,
        ),
      ),
      centerTitle: true,
      onPressLeftIcon: () {
        context.read<OctobeatPairDeviceBloc>().clearTimer();
        _gotoRefCodeScreen();
      },
      displayBottomSeparator: true,
      elevation: ElevationApp.ev16,
      shadowColor: ColorsApp.shadowColor.withOpacity(0.2),
    );
  }
}
