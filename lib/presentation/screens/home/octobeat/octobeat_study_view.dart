import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octo360/application/enum/device_status_enum.dart';
import 'package:octo360/application/enum/device_type_enum.dart';
import 'package:octo360/application/enum/dialog_state_enum.dart';
import 'package:octo360/application/enum/octobeat_trouble_shooting_menu_enum.dart';
import 'package:octo360/application/enum/pairing_state.dart';
import 'package:octo360/data/local/bridge/package/package_manager_plugin.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/data/service/location/localtion_service.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_device_view_bloc.dart';
import 'package:octo360/domain/bloc/home/octobeat/octobeat_study_view_bloc_extension.dart';
import 'package:octo360/domain/model/device/octobeat_device_domain.dart';
import 'package:octo360/domain/model/home/octobeat/octobeat_study_view_state.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/widgets/app_bar/custom_app_bar/custom_app_bar.dart';
import 'package:octo360/presentation/widgets/button/outline_button/outline_button.dart';
import 'package:octo360/presentation/widgets/card/devices_support_card/devices_support_card.dart';
import 'package:octo360/presentation/widgets/card/octobeat_device_card/octobeat_device_card.dart';
import 'package:octo360/presentation/widgets/dialog/custom_dialog/custom_dialog.dart';
import 'package:octo360/presentation/widgets/loading_view/loading_view.dart';
import 'package:octo360/presentation/widgets/section/devices_notice_section/devices_notice_section.dart';
import 'package:octo360/presentation/widgets/section/devices_troubleshoot_section/devices_troubleshoot_section.dart';
import 'package:octo360/presentation/widgets/snack_bar/custom_snackar/custom_snackbar.dart';
import 'package:octo360/presentation/widgets/snack_bar/guide_snackbar/guide_snackbar.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';

class OctoBeatStudyView extends StatefulWidget {
  const OctoBeatStudyView({required this.study, Key? key}) : super(key: key);
  final ECG0StudyByPatientInfo? study;
  @override
  State<OctoBeatStudyView> createState() => _OctoBeatStudyViewState();
}

class _OctoBeatStudyViewState extends State<OctoBeatStudyView>
    with WidgetsBindingObserver {
  var _isShowingDialog = false;

  @override
  void initState() {
    context.read<OctoBeatStudyViewBlocExtension>().pairAndInitstate(
          context: context,
          study: widget.study,
        );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    if (CustomSnackBar.isSnackBarActive) {
      CustomSnackBar.hideSnackBar(context);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumedState();
        break;
      case AppLifecycleState.paused:
        context
            .read<OctoBeatStudyViewBlocExtension>()
            .cancelBluetoothListener();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body:
          BlocListener<OctoBeatStudyViewBlocExtension, OctoBeatStudyViewState>(
        listenWhen: (previous, current) =>
            previous.dialogState != current.dialogState,
        listener: (context, state) {
          _handleDialogListener(state.dialogState);
        },
        child: Container(
          color: ColorsApp.fogBackground,
          child: Stack(
            children: [
              _renderBody(),
              _renderNotice(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return CustomAppBar(
      titleWidget: Text(
        StringsApp.home,
        style: TextStylesApp.bold(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s16,
          lineHeight: SizeApp.s24,
        ),
      ),
      leftIconButtonConstraints: const BoxConstraints(maxWidth: SizeApp.s28),
      marginLeftIcon: MarginApp.m8,
      leftIconsSpacing: MarginApp.m12,
      backgroundColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    );
  }

  Widget _renderBody() {
    return BlocConsumer<OctoBeatStudyViewBlocExtension, OctoBeatStudyViewState>(
      bloc: context.read<OctoBeatStudyViewBlocExtension>(),
      listenWhen: (previous, current) =>
          previous.screenState != current.screenState ||
          previous.octobeatDevice?.studyStatus !=
              current.octobeatDevice?.studyStatus,
      listener: (context, state) {
        _blocListener(context, state);
      },
      builder: (context, state) {
        if (state.screenState == OctoBeatViewState.loading) {
          return const LoadingView();
        }
        return _renderListData();
      },
    );
  }

  void _blocListener(BuildContext ctx, OctoBeatStudyViewState state) {
    switch (state.screenState) {
      case OctoBeatViewState.failed:
        if (!CustomSnackBar.isSnackBarActive) {
          CustomSnackBar.displaySnackBar(
            duration: const Duration(days: 365),
            context: context,
            message: StringsApp.somethingWentWrong,
            imagePath: ImagesApp.icFailed,
            customActionLabel: StringsApp.tryAgain,
            customActionLabelColor: ColorsApp.orangeBase,
            marginBottom: MarginApp.m16,
            customAction: () {
              CustomSnackBar.hideSnackBar(context);
              context.read<OctoBeatStudyViewBlocExtension>().onPressTryAgain();
            },
          );
        }
        break;
      case OctoBeatViewState.success:
        if (CustomSnackBar.isSnackBarActive) {
          CustomSnackBar.hideSnackBar(context);
        }
        break;
      case OctoBeatViewState.studyCompleted:
        _showBiotresStudyCompletedDialog();
        break;
      case OctoBeatViewState.removed:
        context.read<OctoBeatDeviceViewBloc>().onDisconnectedDevice();
        break;
      default:
    }
  }

  void _showBiotresStudyCompletedDialog() {
    if (!_isShowingDialog) {
      _isShowingDialog = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return CustomDialog(
            imagePath: ImagesApp.success,
            title: StringsApp.completedStudy,
            message: StringsApp.yourStudyOnOctobeatHas,
            positiveButtonText: StringsApp.okay,
            onPressPositiveButton: () async {
              NavigationApp.popDialog(dialogContext);
              _isShowingDialog = false;
              SharedPref.setHasShowCompletedStudyDialog(true);
              context.read<OctoBeatDeviceViewBloc>().onDisconnectedDevice();
            },
          );
        },
      );
    }
  }

  Widget _renderNotice() {
    return BlocBuilder<OctoBeatStudyViewBlocExtension, OctoBeatStudyViewState>(
      bloc: context.read<OctoBeatStudyViewBlocExtension>(),
      builder: (context, state) {
        if (state.screenState == OctoBeatViewState.noInternet) {
          return GuideSnackBar(
            icon: ImagesApp.icFailed,
            message: StringsApp.noInternetConnectionTitle,
            tilteButton: StringsApp.settings,
            onTap: () {
              PackageManagerPlugin.openWifiSetting();
            },
          );
        }

        if (state.screenState == OctoBeatViewState.failed) {
          return const SizedBox.shrink();
        }
        return BlocSelector<OctoBeatStudyViewBlocExtension,
            OctoBeatStudyViewState, DevicesStatusEnum>(
          bloc: context.read<OctoBeatStudyViewBlocExtension>(),
          selector: (state) {
            return state.noticeEnum;
          },
          builder: (context, state) {
            if (state == DevicesStatusEnum.none) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.only(
                  left: PaddingApp.p16,
                  right: PaddingApp.p16,
                  bottom: PaddingApp.p8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DevicesNoticeSection(
                    devicesStatus: state,
                    onPressedButton: () {
                      context
                          .read<OctoBeatStudyViewBlocExtension>()
                          .onHideNotice();
                    },
                    deviceType: DeviceTypeEnum.octoBeat,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _renderListData() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<OctoBeatStudyViewBlocExtension, OctoBeatStudyViewState>(
              bloc: context.read<OctoBeatStudyViewBlocExtension>(),
              builder: (context, state) {
                return Column(
                  children: [
                    _renderDeviceCard(state),
                    _renderAttentionAlert(state),
                    _renderSupportCard(),
                  ],
                );
              },
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: MarginApp.m12),
              child: OutlinedButtonApp(
                label: StringsApp.leaveMonitoring,
                borderColor: ColorsApp.redBase,
                borderWidth: 1,
                colorText: ColorsApp.redBase,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return CustomDialog(
                        isErrorDialog: true,
                        imagePath: ImagesApp.attention,
                        title: StringsApp.leaveMonitoring,
                        message: StringsApp.areYouSureYouWishRemove,
                        positiveButtonText: StringsApp.remove,
                        negativeButtonText: StringsApp.cancel,
                        onPressPositiveButton: () async {
                          NavigationApp.popDialog(ctx);
                          await context
                              .read<OctoBeatStudyViewBlocExtension>()
                              .removeDevice();
                          Future.delayed(Duration.zero, () {
                            NavigationApp.back(context);
                          });
                        },
                        onPressNegativeButton: () {
                          NavigationApp.popDialog(ctx);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _renderSupportCard() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m12),
      child: DevicesSupportCard(
        deviceType: DeviceTypeEnum.octoBeat,
      ),
    );
  }

  Container _renderDeviceCard(OctoBeatStudyViewState state) {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m12),
      child: Column(
        children: [
          OctoBeatDeviceCard(
            device: state.octobeatDevice ??
                OctobeatDeviceDomain(
                    studyId: '',
                    friendlyId: '',
                    deviceId: '',
                    latSyncTime: DateTime.now(),
                    isDeviceOnline: false,
                    isConnected: false,
                    lastLeadDisconnectedAt: DateTime.now()),
            isBluetoothConntected:
                state.warningEnum != DevicesStatusEnum.bluetoothTurnOff,
          ),
        ],
      ),
    );
  }

  Widget _renderAttentionAlert(OctoBeatStudyViewState state) {
    if (state.warningEnum != DevicesStatusEnum.none) {
      return Container(
        margin: const EdgeInsets.only(top: MarginApp.m12),
        child: DevicesTroubleshootSection(
          deviceType: DeviceTypeEnum.octoBeat,
          devicesStatus: state.warningEnum,
          onPressedButton: () {
            switch (state.warningEnum) {
              case DevicesStatusEnum.bluetoothTurnOff:
                context
                    .read<OctoBeatStudyViewBlocExtension>()
                    .handleStep(PairingState.checkPermission);
                break;
              case DevicesStatusEnum.offlineTroubleshoot:
                NavigationApp.routeTo(
                  context,
                  Routes.octoBeatTroubleshootingRoute,
                  agrs: {
                    "selectItem":
                        OctoBeatTroubleShootingMenuEnum.serverConnection
                  },
                );
                break;
              default:
            }
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  //CONNECT DEVICE FLOW
  _handleResumedState() async {
    final pairingState =
        context.read<OctoBeatStudyViewBlocExtension>().state.pairingState;
    final device = await OctoBeatPlugin.getDeviceInfo();
    if (device == null) {
      Future.delayed(Duration.zero, () {
        context
            .read<OctoBeatStudyViewBlocExtension>()
            .restartBluetoothListener();
      });
      switch (pairingState) {
        case PairingState.checkLocation:
          bool serviceEnabled = await LocationService.isEnable();
          if (!serviceEnabled) {}
          break;
        case PairingState.checkPermission:
        case PairingState.scanning:
          Future.delayed(Duration.zero, () {
            context.read<OctoBeatStudyViewBlocExtension>().handlePermission();
          });

          break;
        case PairingState.checkBluetooth:
          Future.delayed(Duration.zero, () {
            NavigationApp.popUntil(context, Routes.octoBeatDeviceViewRoute);
            context
                .read<OctoBeatStudyViewBlocExtension>()
                .checkBluetoothState();
          });
          break;
        default:
      }
    }
  }

  _handleDialogListener(DialogState? dialogState) {
    // NavigationApp.popUntil(context, Routes.octoBeatPairDeviceRoute);
    switch (dialogState) {
      case DialogState.requireBluetoothPermission:
        _showBluetoothPermissionDialog();
        break;
      case DialogState.requireLocationPermission:
        _showLocationPermissionDialog();
        break;
      case DialogState.bluetoothNotAvailable:
        _showBluetoothUnavailableDialog();
        break;
      case DialogState.locationNotAvailable:
        break;
      case DialogState.pairingDevice:
        break;
      case DialogState.pairingFailed:
        break;
      case DialogState.somethingWentWrong:
        break;
      case DialogState.connectSuccess:
        break;
      case DialogState.failedToStartStudy:
        break;
      default:
        break;
    }
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
                NavigationApp.pop(context);
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
                NavigationApp.pop(context);
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
              NavigationApp.pop(context);
            },
          ),
        );
      },
    );
  }
}
