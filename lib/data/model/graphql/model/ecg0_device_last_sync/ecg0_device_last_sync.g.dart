// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_device_last_sync.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0DeviceLastSync _$ECG0DeviceLastSyncFromJson(Map<String, dynamic> json) =>
    ECG0DeviceLastSync(
      time:
          json['time'] == null ? null : DateTime.parse(json['time'] as String),
      batteryLevel: json['batteryLevel'] as int?,
      isCharging: json['isCharging'] as bool?,
      leadOn: json['leadOn'] as bool?,
    );

Map<String, dynamic> _$ECG0DeviceLastSyncToJson(ECG0DeviceLastSync instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('time', instance.time?.toIso8601String());
  writeNotNull('batteryLevel', instance.batteryLevel);
  writeNotNull('isCharging', instance.isCharging);
  writeNotNull('leadOn', instance.leadOn);
  return val;
}
