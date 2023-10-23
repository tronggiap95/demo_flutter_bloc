// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_study_patient_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0StudyByPatientInfo _$ECG0StudyByPatientInfoFromJson(
        Map<String, dynamic> json) =>
    ECG0StudyByPatientInfo(
      id: json['id'] as String?,
      friendlyId: json['friendlyId'] as int?,
      deviceId: json['deviceId'] as String?,
      start: json['start'] == null
          ? null
          : DateTime.parse(json['start'] as String),
      stop:
          json['stop'] == null ? null : DateTime.parse(json['stop'] as String),
      status: json['status'] as String?,
      deviceType: json['deviceType'] as String?,
      device: json['device'] == null
          ? null
          : ECG0Device.fromJson(json['device'] as Map<String, dynamic>),
      artifact: json['artifact'] == null
          ? null
          : ECG0ArtifactStatistic.fromJson(
              json['artifact'] as Map<String, dynamic>),
      lastStudyHistory: json['lastStudyHistory'] == null
          ? null
          : ECG0StudyHistoryItem.fromJson(
              json['lastStudyHistory'] as Map<String, dynamic>),
      referenceCode: json['referenceCode'] as String?,
      lastLeadDisconnectedAt: json['lastLeadDisconnectedAt'] == null
          ? null
          : DateTime.parse(json['lastLeadDisconnectedAt'] as String),
      facility: json['facility'] == null
          ? null
          : ECG0Facility.fromJson(json['facility'] as Map<String, dynamic>),
      info: json['info'] == null
          ? null
          : ECG0StudyInfo.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ECG0StudyByPatientInfoToJson(
    ECG0StudyByPatientInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('friendlyId', instance.friendlyId);
  writeNotNull('deviceId', instance.deviceId);
  writeNotNull('start', instance.start?.toIso8601String());
  writeNotNull('stop', instance.stop?.toIso8601String());
  writeNotNull('status', instance.status);
  writeNotNull('deviceType', instance.deviceType);
  writeNotNull('device', instance.device?.toJson());
  writeNotNull('artifact', instance.artifact?.toJson());
  writeNotNull('lastStudyHistory', instance.lastStudyHistory?.toJson());
  writeNotNull('lastLeadDisconnectedAt',
      instance.lastLeadDisconnectedAt?.toIso8601String());
  writeNotNull('referenceCode', instance.referenceCode);
  writeNotNull('facility', instance.facility?.toJson());
  writeNotNull('info', instance.info?.toJson());
  return val;
}
