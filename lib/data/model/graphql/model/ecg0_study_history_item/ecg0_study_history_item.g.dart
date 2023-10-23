// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_study_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0StudyHistoryItem _$ECG0StudyHistoryItemFromJson(
        Map<String, dynamic> json) =>
    ECG0StudyHistoryItem(
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      batteryLevel: json['batteryLevel'] as int?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ECG0StudyHistoryItemToJson(
    ECG0StudyHistoryItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('time', instance.time?.toIso8601String());
  writeNotNull('batteryLevel', instance.batteryLevel);
  writeNotNull('status', instance.status);
  return val;
}
