// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactInput _$ContactInputFromJson(Map<String, dynamic> json) => ContactInput(
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      timezone: json['timezone'] as int?,
      phone1: json['phone1'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$ContactInputToJson(ContactInput instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address);
  writeNotNull('city', instance.city);
  writeNotNull('country', instance.country);
  writeNotNull('state', instance.state);
  writeNotNull('timezone', instance.timezone);
  writeNotNull('phone1', instance.phone1);
  writeNotNull('zip', instance.zip);
  return val;
}
