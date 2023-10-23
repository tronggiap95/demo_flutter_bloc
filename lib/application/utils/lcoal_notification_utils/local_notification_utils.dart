import 'dart:convert';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:octo360/application/enum/notification_enum.dart';
import 'package:octo360/data/local/bridge/octo_beat/handler/octo_beat_symtoms_trigger_handler.dart';
import 'package:octo360/data/local/notification/local_notification_modal/local_notification_modal.dart';
import 'package:octo360/data/local/notification/local_notification_services.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:octo360/data/repository/global/variables_global.dart'
    as globals;

class LocalNotificationUtils {
  static int formatIdNotification(
      tz.TZDateTime dateTime, bool isRepeat, LocalNotificationType type) {
    final randomNum = randomNumber();
    // idNotification format: 101000000 -> 999899999
    final idNotification = type.getId + randomNum.toString();
    return int.parse(idNotification);
  }

  static int randomNumber() {
    return 1000000 + Random().nextInt(9899999 - 1000000);
  }

  static ConvertIdNotification? convertFormatNotification(int notificationId) {
    var idToString = notificationId.toString();
    final convertId = ConvertIdNotification(
        id: notificationId,
        type: LocalNotificationType.getTypeFromNumber(
            idToString[0] + idToString[1]));
    return convertId;
  }

  static Future<void> cancelAllDeliveryNotificationType(
      LocalNotificationType type) async {
    final listPending =
        await LocalNotificationServices.checkPendingNotificationRequests();
    for (var itemNoti in listPending) {
      if (itemNoti.toString().length == 9) {
        ConvertIdNotification? itemNotiConvert =
            convertFormatNotification(itemNoti);
        if (itemNotiConvert?.type == type) {
          await LocalNotificationServices.cancelNotification(itemNoti);
        }
      }
    }
  }

  static Future<void> handleOpenLocalNotification(
      NotificationResponse notificationResponse) async {
    try {
      if (notificationResponse.payload != '') {
        globals.isTouchNotification = true;
        final parseData =
            Payload.fromJson(jsonDecode(notificationResponse.payload!));
        final fromNoti = FromNotification(
            scheduleTime: parseData.scheduleTime,
            localNotificationType: parseData.localNotificationType,
            data: parseData.data);
        await SharedPref.setFromNotification(fromNoti);
        LocalNotificationServices.selectNotificationStream.add(FromNotification(
            scheduleTime: parseData.scheduleTime,
            localNotificationType: parseData.localNotificationType,
            data: parseData.data));
      }
      // ignore: empty_catches
    } catch (error) {}
  }

  static DateTime tzDaytimeToDatetime(tz.TZDateTime tzDaytime) {
    DateTime scheduledDate = DateTime(tzDaytime.year, tzDaytime.month,
        tzDaytime.day, tzDaytime.hour, tzDaytime.minute);
    return scheduledDate;
  }

  static Future<void> handleNotificationNavigation(context) async {
    final localNotificationPressed = await SharedPref.getFromNotification();
    await SharedPref.removeFromNotification();
    if (localNotificationPressed != null) {
      final localNotificationType =
          localNotificationPressed.localNotificationType;
      final dataPayload = localNotificationPressed.data;
      final scheduleTime = localNotificationPressed.scheduleTime;
      switch (localNotificationType) {
        case LocalNotificationType.octoBeatSymptomsTrigger:
          await OctoBeatSymtomsTriggerHandler.handleOpenOctoBeatSymptomsNotif(
              context, localNotificationPressed.data);
          break;
        default:
          break;
      }
    }
    //* return false when handled open notif
    globals.isTouchNotification = false;
  }
}
