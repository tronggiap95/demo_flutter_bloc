// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:octo360/application/enum/notification_enum.dart';
import 'package:timezone/timezone.dart';

part 'local_notification_modal.g.dart';

@JsonSerializable(explicitToJson: true)
class Payload {
  Payload({
    required this.localNotificationType,
    required this.data,
    required this.scheduleTime,
  });

  final LocalNotificationType localNotificationType;
  final String data;
  final DateTime scheduleTime;

  @override
  String toString() =>
      'Payload(localNotificationType: $localNotificationType, data: $data, scheduleTime: $scheduleTime)';

  factory Payload.fromJson(Map<String, dynamic> json) =>
      _$PayloadFromJson(json);

  Map<String, dynamic> toJson() => _$PayloadToJson(this);
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class ConvertIdNotification {
  ConvertIdNotification({
    required this.id,
    required this.type,
    this.isRepeat,
    this.dateTime,
  });
  final int id;
  final LocalNotificationType type;
  final bool? isRepeat;
  final String? dateTime;
}

class SendNotification {
  SendNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.dayTime,
    this.isRepeat,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
  TZDateTime? dayTime;
  final bool? isRepeat;
}

@JsonSerializable(explicitToJson: true)
class FromNotification {
  FromNotification({
    required this.localNotificationType,
    required this.data,
    required this.scheduleTime,
  });

  final LocalNotificationType localNotificationType;
  final String data;
  final DateTime scheduleTime;

  @override
  String toString() =>
      'FromNotification(localNotificationType: $localNotificationType, payLoad: $data)';

  factory FromNotification.fromJson(Map<String, dynamic> json) =>
      _$FromNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$FromNotificationToJson(this);
}
