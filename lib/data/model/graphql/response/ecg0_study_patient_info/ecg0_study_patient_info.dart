// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/application/enum/artifact_issue_enum.dart';
import 'package:octo360/application/enum/battery_connection_status.dart';
import 'package:octo360/application/enum/octo_device_status_enum.dart';
import 'package:octo360/application/enum/electrodes_status_enum.dart';
import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo360/application/utils/device/octomed_device_util.dart';
import 'package:octo360/data/model/graphql/model/ecg0_artifact_statistic/ecg0_artifact_statistic.dart';
import 'package:octo360/data/model/graphql/model/ecg0_facility/ecg0_facility.dart';
import 'package:octo360/data/model/graphql/model/ecg0_study_history_item/ecg0_study_history_item.dart';
import 'package:octo360/data/model/graphql/model/ecg0_study_info/ecg0_study_info.dart';
import 'package:octo360/data/model/graphql/model/ecg0_device/ecg0_device.dart';
import 'package:octo360/domain/model/device/follow_on_study_domain.dart';
import 'package:octo360/domain/model/device/octobeat_device_domain.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';

part 'ecg0_study_patient_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ECG0StudyByPatientInfo {
  final String? id;
  final int? friendlyId;
  final String? deviceId;
  final DateTime? start;
  final DateTime? stop;
  final String? status;
  final String? deviceType;
  final ECG0Device? device;
  final ECG0ArtifactStatistic? artifact;
  final ECG0StudyHistoryItem? lastStudyHistory;
  final DateTime? lastLeadDisconnectedAt;
  final String? referenceCode;
  final ECG0Facility? facility;
  final ECG0StudyInfo? info;

  ECG0StudyByPatientInfo({
    required this.id,
    this.friendlyId,
    this.deviceId,
    this.start,
    this.stop,
    this.status,
    this.deviceType,
    this.device,
    this.artifact,
    this.lastStudyHistory,
    this.referenceCode,
    this.lastLeadDisconnectedAt,
    this.facility,
    this.info,
  });

  factory ECG0StudyByPatientInfo.fromJson(Map<String, dynamic> json) =>
      _$ECG0StudyByPatientInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ECG0StudyByPatientInfoToJson(this);

  OctobeatDeviceDomain toDomain() {
    final isDeviceOnline =
        OctoDeviceStatus.from(device?.status) != OctoDeviceStatus.offline;
    final batteryStatus = BatteryConnectionStatus.from(
        device?.lastSync?.isCharging ?? false,
        device?.lastSync?.batteryLevel ?? 0);
    final electrodesStatus = ElectrodesStatus.from(device?.lastSync?.leadOn);
    final studyStatus = OctoBeatStudyStatus.from(
          lastStudyHistory?.status ?? '',
        ) ??
        OctoBeatStudyStatus.studyPaused;

    return OctobeatDeviceDomain(
      studyId: id,
      friendlyId: '$friendlyId'.padLeft(5, '0'),
      deviceId: deviceId ?? '',
      isDeviceOnline: isDeviceOnline,
      latSyncTime: device?.lastSync?.time ?? DateTime.now(),
      electrodesConnectionStatus: electrodesStatus,
      batteryStatus: batteryStatus,
      batteryLevel: device?.lastSync?.batteryLevel,
      studyStatus: studyStatus,
      studyProgress: calculateStudyProgress(start, stop),
      remainStudyTime: DeviceUtil.calculateRemainingTime(start, stop),
      isCommonIssueFound: artifact?.shouldBeResolved ?? false,
      commonIssue:
          ArtifactIssueEnum.from(artifact?.lastIssueFound)?.getDisplayValue ??
              '',
      startStudyTime: start,
      stopStudyTime: stop,
      lastLeadDisconnectedAt: lastLeadDisconnectedAt ?? DateTime.now(),
      referenceCode: referenceCode,
      followOnStudy: FollowOnStudyDomain(
        studyType: info?.followOnStudy?.studyType,
      ),
    ); //need a format from BA
  }

  double? calculateStudyProgress(DateTime? start, DateTime? stop) {
    if (start == null || stop == null) {
      return null;
    }

    final duration = stop.difference(start).inMinutes.toDouble();
    final spentDuration = DateTime.now().difference(start).inMinutes.toDouble();
    final percent = (spentDuration / duration);
    final result = percent > 1 ? 1.0 : percent;
    return result < 0 ? 0 : result;
  }

  @override
  String toString() {
    return 'ECG0StudyByPatientInfo(id: $id, friendlyId: $friendlyId, deviceId: $deviceId, start: $start, stop: $stop, status: $status, deviceType: $deviceType, device: $device, artifact: $artifact, lastStudyHistory: $lastStudyHistory, lastLeadDisconnectedAt: $lastLeadDisconnectedAt)';
  }
}
