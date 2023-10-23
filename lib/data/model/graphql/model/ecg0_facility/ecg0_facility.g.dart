// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecg0_facility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ECG0Facility _$ECG0FacilityFromJson(Map<String, dynamic> json) => ECG0Facility(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ECG0FacilityToJson(ECG0Facility instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  return val;
}
