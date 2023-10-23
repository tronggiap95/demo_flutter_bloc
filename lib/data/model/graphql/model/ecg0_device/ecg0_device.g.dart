// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0Device _$ECG0DeviceFromJson(Map<String, dynamic> json) => ECG0Device(
      id: json['id'] as String?,
      deviceId: json['deviceId'] as String?,
      status: json['status'] as String?,
      lastSync: json['lastSync'] == null
          ? null
          : ECG0DeviceLastSync.fromJson(
              json['lastSync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ECG0DeviceToJson(ECG0Device instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('deviceId', instance.deviceId);
  writeNotNull('status', instance.status);
  writeNotNull('lastSync', instance.lastSync?.toJson());
  return val;
}
