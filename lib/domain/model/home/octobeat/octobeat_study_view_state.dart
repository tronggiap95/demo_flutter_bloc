import 'package:octo360/application/enum/device_status_enum.dart';
import 'package:octo360/application/enum/dialog_state_enum.dart';
import 'package:octo360/application/enum/pairing_state.dart';
import 'package:octo360/domain/model/device/octobeat_device_domain.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';

enum OctoBeatViewState {
  none,
  loading,
  success,
  failed,
  noInternet,
  showFirstGuide,
  disconnect,
  studyCompleted,
  removed
}

class OctoBeatStudyViewState {
  OctoBeatViewState screenState;
  bool isShowIndicator;
  OctobeatDeviceDomain? octobeatDevice;
  DevicesStatusEnum noticeEnum;
  DevicesStatusEnum warningEnum;
  OctoBeatStudyStatus? previousStudyStatus;
  DevicesStatusEnum? lastNoticeHide;
  DateTime? lastTimeHideNotice;
  String? phone;
  String? patientId;
  //Pair device state
  PairingState? pairingState;
  DialogState? dialogState;
  String? deviceId;
  String? deviceAddress;

  OctoBeatStudyViewState({
    this.screenState = OctoBeatViewState.none,
    this.isShowIndicator = false,
    this.octobeatDevice,
    this.noticeEnum = DevicesStatusEnum.none,
    this.warningEnum = DevicesStatusEnum.none,
    this.previousStudyStatus,
    this.lastNoticeHide,
    this.lastTimeHideNotice,
    this.phone,
    this.patientId,
    this.pairingState = PairingState.scanning,
    this.dialogState = DialogState.none,
    this.deviceId,
    this.deviceAddress,
  });

  OctoBeatStudyViewState resetState() {
    return OctoBeatStudyViewState(
      screenState: OctoBeatViewState.none,
      isShowIndicator: false,
      octobeatDevice: null,
      noticeEnum: DevicesStatusEnum.none,
      warningEnum: DevicesStatusEnum.none,
      phone: phone,
      patientId: patientId,
      pairingState: PairingState.scanning,
      dialogState: DialogState.none,
      deviceId: deviceId,
      deviceAddress: deviceAddress,
    );
  }

  OctoBeatStudyViewState copyWith({
    OctoBeatViewState? screenState,
    bool? isShowIndicator,
    OctobeatDeviceDomain? device,
    DevicesStatusEnum? noticeEnum,
    DevicesStatusEnum? warningEnum,
    OctoBeatStudyStatus? previousStudyStatus,
    DateTime? lastTimeHideNotice,
    DevicesStatusEnum? lastNoticeHide,
    String? phone,
    String? patientId,
    PairingState? pairingState,
    DialogState? dialogState,
    String? deviceId,
    String? deviceAddress,
  }) {
    return OctoBeatStudyViewState(
      screenState: screenState ?? this.screenState,
      isShowIndicator: isShowIndicator ?? this.isShowIndicator,
      octobeatDevice: device ?? octobeatDevice,
      noticeEnum: noticeEnum ?? this.noticeEnum,
      warningEnum: warningEnum ?? this.warningEnum,
      previousStudyStatus: previousStudyStatus ?? this.previousStudyStatus,
      lastTimeHideNotice: lastTimeHideNotice,
      lastNoticeHide: lastNoticeHide,
      phone: phone ?? this.phone,
      patientId: patientId ?? this.patientId,
      pairingState: pairingState ?? this.pairingState,
      dialogState: dialogState ?? this.dialogState,
      deviceId: deviceId ?? this.deviceId,
      deviceAddress: deviceAddress ?? this.deviceAddress,
    );
  }
}
