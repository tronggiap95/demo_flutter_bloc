import 'package:octo360/application/enum/artifact_issue_enum.dart';
import 'package:octo360/application/enum/battery_connection_status.dart';
import 'package:octo360/application/enum/electrodes_status_enum.dart';

import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo360/application/utils/device/octomed_device_util.dart';
import 'package:octo360/data/model/graphql/response/ecg0_study_patient_info/ecg0_study_patient_info.dart';
import 'package:octo360/domain/model/device/follow_on_study_domain.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo_beat_plugin/model/octo_beat_device.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';

class OctobeatDeviceDomain {
  String? studyId;
  String? friendlyId;
  final String deviceId;
  DateTime? latSyncTime;
  DateTime? lastLeadDisconnectedAt;
  bool isDeviceOnline;
  int? batteryLevel;
  ElectrodesStatus electrodesConnectionStatus;
  BatteryConnectionStatus batteryStatus;
  String remainStudyTime;
  double? studyProgress;
  OctoBeatStudyStatus studyStatus;
  bool isCommonIssueFound;
  String commonIssue;
  int batTime;
  bool isConnected;

  DateTime? startStudyTime;
  DateTime? stopStudyTime;
  String? referenceCode;
  FollowOnStudyDomain? followOnStudy;

  OctobeatDeviceDomain({
    this.studyId,
    this.friendlyId,
    required this.deviceId,
    this.latSyncTime,
    this.isDeviceOnline = false,
    this.lastLeadDisconnectedAt,
    this.batteryLevel,
    this.electrodesConnectionStatus = ElectrodesStatus.none,
    this.batteryStatus = BatteryConnectionStatus.normal,
    this.remainStudyTime = '',
    this.studyProgress,
    this.studyStatus = OctoBeatStudyStatus.studyPaused,
    this.isCommonIssueFound = false,
    this.commonIssue = '',
    this.startStudyTime,
    this.stopStudyTime,
    this.batTime = 0,
    this.isConnected = false,
    this.referenceCode,
    this.followOnStudy,
  });

  String getProgressStatusString({bool? isCardStatus = false}) {
    if (!isConnected) {
      return '';
    }

    switch (studyStatus) {
      case OctoBeatStudyStatus.studyPaused:
        return isCardStatus == true
            ? StringsApp.studyPaused
            : StringsApp.paused;
      case OctoBeatStudyStatus.setting:
        return StringsApp.settingUp;
      case OctoBeatStudyStatus.studyUploading:
        return StringsApp.dataUploading;
      case OctoBeatStudyStatus.studyUploaded:
        return StringsApp.dataUploaded;
      case OctoBeatStudyStatus.studyCompleted:
        return StringsApp.completed;
      default:
    }

    return remainStudyTime.isEmpty ? '' : '$remainStudyTime ${StringsApp.left}';
  }

  String formatRemainingTime() {
    if (isConnected) {
      if (batteryLevel == 0 && batTime == 0) {
        return '--';
      }
      final isCharging = batteryStatus == BatteryConnectionStatus.charging;
      if (batTime == 0) {
        return isCharging ? StringsApp.fullyCharged : '--';
      }

      final h = batTime ~/ 60;
      final m = batTime % 60;

      final hStr = '$h${StringsApp.h}';
      final mStr = '${DateTimeUtils.displayMinute(m)}${StringsApp.m}';

      if (h == 0) {
        return mStr;
      } else if (m == 0) {
        return hStr;
      } else {
        return '$hStr $mStr';
      }
    }
    return '-';
  }

  OctobeatDeviceDomain updateInfo(OctoBeatDevice device) {
    var newStudyStatus = studyStatus;
    if (device.studyStatus == OctoBeatStudyStatus.ready) {
      newStudyStatus = OctoBeatStudyStatus.ready;
    }
    return OctobeatDeviceDomain(
      studyId: studyId,
      friendlyId: friendlyId,
      deviceId: deviceId,
      isDeviceOnline: device.isServerConnected,
      isConnected: device.isConnected,
      latSyncTime: latSyncTime,
      electrodesConnectionStatus: ElectrodesStatus.from(device.isLeadConnected),
      batteryStatus: BatteryConnectionStatus.from(
        device.isCharging,
        device.batLevel,
      ),
      batteryLevel: device.batLevel,
      batTime: device.batTime,
      studyStatus: newStudyStatus,
      studyProgress: DeviceUtil.calculateStudyProgress(
          startStudyTime, stopStudyTime, newStudyStatus),
      remainStudyTime:
          DeviceUtil.calculateRemainingTime(startStudyTime, stopStudyTime),
      isCommonIssueFound: isCommonIssueFound,
      commonIssue: commonIssue,
      startStudyTime: startStudyTime,
      stopStudyTime: stopStudyTime,
      lastLeadDisconnectedAt:
          !device.isLeadConnected ? DateTime.now() : lastLeadDisconnectedAt,
    );
  }

  @override
  String toString() {
    return 'OctobeatDeviceDomain(studyId: $studyId, deviceId: $deviceId, latSyncTime: $latSyncTime, isDeviceOnline: $isDeviceOnline, batteryLevel: $batteryLevel, electrodesConnectionStatus: $electrodesConnectionStatus, batteryStatus: $batteryStatus, remainStudyTime: $remainStudyTime, studyProgress: $studyProgress, studyStatus: $studyStatus, isCommonIssueFound: $isCommonIssueFound, commonIssue: $commonIssue, startStudyTime: $startStudyTime, stopStudyTime: $stopStudyTime, lastLeadDisconnectedAt: $lastLeadDisconnectedAt)';
  }
}

extension OctobeatDeviceDomainAdapter on OctoBeatDevice {
  OctobeatDeviceDomain toDomain(ECG0StudyByPatientInfo? study) {
    final start = study?.start ?? DateTime.now();
    final stop = study?.stop ?? DateTime.now();
    final newStudyStaus = OctoBeatStudyStatus.fromECG0StudyStatus(
          studyStatus: study?.status,
          lastHistoryStudyStatus: study?.lastStudyHistory?.status,
        ) ??
        studyStatus ??
        OctoBeatStudyStatus.studyPaused;

    return OctobeatDeviceDomain(
      studyId: study?.id ?? '',
      friendlyId:
          study != null ? study.friendlyId.toString().padLeft(5, '0') : '',
      deviceId: name,
      isDeviceOnline: isServerConnected,
      isConnected: isConnected,
      latSyncTime: study?.lastStudyHistory?.time ?? DateTime.now(),
      electrodesConnectionStatus: ElectrodesStatus.from(isLeadConnected),
      batteryStatus: BatteryConnectionStatus.from(
        isCharging,
        batLevel,
      ),
      batteryLevel: batLevel,
      batTime: batTime,
      studyStatus: newStudyStaus,
      studyProgress: DeviceUtil.calculateStudyProgress(
        start,
        stop,
        newStudyStaus,
      ),
      remainStudyTime: DeviceUtil.calculateRemainingTime(start, stop),
      isCommonIssueFound: study?.artifact?.shouldBeResolved ?? false,
      commonIssue: ArtifactIssueEnum.from(study?.artifact?.lastIssueFound)
              ?.getDisplayValue ??
          '',
      startStudyTime: start,
      stopStudyTime: stop,
      lastLeadDisconnectedAt: study?.lastLeadDisconnectedAt ?? DateTime.now(),
    );
  }
}
