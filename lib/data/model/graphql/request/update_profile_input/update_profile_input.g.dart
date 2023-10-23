// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileInput _$UpdateProfileInputFromJson(Map<String, dynamic> json) =>
    UpdateProfileInput(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      contact: json['contact'] == null
          ? null
          : ContactInput.fromJson(json['contact'] as Map<String, dynamic>),
      utcOffset: json['utcOffset'] as int?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$UpdateProfileInputToJson(UpdateProfileInput instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('firstName', instance.firstName);
  writeNotNull('lastName', instance.lastName);
  writeNotNull('contact', instance.contact);
  writeNotNull('utcOffset', instance.utcOffset);
  writeNotNull('timezone', instance.timezone);
  return val;
}
