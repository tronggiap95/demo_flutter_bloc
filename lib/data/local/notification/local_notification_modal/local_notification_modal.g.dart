// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payload _$PayloadFromJson(Map<String, dynamic> json) => Payload(
      localNotificationType: $enumDecode(
          _$LocalNotificationTypeEnumMap, json['localNotificationType']),
      data: json['data'] as String,
      scheduleTime: DateTime.parse(json['scheduleTime'] as String),
    );

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'localNotificationType':
          _$LocalNotificationTypeEnumMap[instance.localNotificationType]!,
      'data': instance.data,
      'scheduleTime': instance.scheduleTime.toIso8601String(),
    };

const _$LocalNotificationTypeEnumMap = {
  LocalNotificationType.none: 'none',
  LocalNotificationType.octoBeatSymptomsTrigger: 'octoBeatSymptomsTrigger',
};

FromNotification _$FromNotificationFromJson(Map<String, dynamic> json) =>
    FromNotification(
      localNotificationType: $enumDecode(
          _$LocalNotificationTypeEnumMap, json['localNotificationType']),
      data: json['data'] as String,
      scheduleTime: DateTime.parse(json['scheduleTime'] as String),
    );

Map<String, dynamic> _$FromNotificationToJson(FromNotification instance) =>
    <String, dynamic>{
      'localNotificationType':
          _$LocalNotificationTypeEnumMap[instance.localNotificationType]!,
      'data': instance.data,
      'scheduleTime': instance.scheduleTime.toIso8601String(),
    };
