// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
      json['address'] as String?,
      json['city'] as String?,
      json['country'] as String?,
      json['state'] as String?,
      json['timezone'] as int?,
      json['zip'] as String?,
      json['phone1'] as String?,
    );

Map<String, dynamic> _$ContactToJson(Contact instance) {
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
  writeNotNull('zip', instance.zip);
  writeNotNull('phone1', instance.phone1);
  return val;
}
