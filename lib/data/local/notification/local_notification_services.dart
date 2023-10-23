import 'dart:async';
import 'dart:io';
import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo360/application/utils/lcoal_notification_utils/local_notification_utils.dart';
import 'package:octo360/application/utils/logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:octo360/data/local/notification/local_notification_modal/local_notification_modal.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String channelId = 'octo360_high_importance_channel_remote';
const String channelTitle = 'High Importance Remote Notifications';
const String channelDescription =
    'This channel is used for important remote notifications.';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse notificationResponse) async {
  // RemoteNotificationService.onPressedNotificationInBackground(
  //     notificationResponse);
  Log.e("onPressedNotificationInBackground");
  await LocalNotificationUtils.handleOpenLocalNotification(
      notificationResponse);
}

// ! iOS pending notifications limit
// ! There is a limit imposed by iOS where it will only keep 64 notifications that will fire the soonest.
class LocalNotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();
  static final StreamController<FromNotification> selectNotificationStream =
      StreamController<FromNotification>.broadcast();

  static Future<void> init() async {
    configureLocalTimeZone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final didNotificationLaunchApp =
        notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

    if (didNotificationLaunchApp) {
      // RemoteNotificationService.onPressedNotificationInBackground(
      //     notificationAppLaunchDetails!.notificationResponse!);
      await LocalNotificationUtils.handleOpenLocalNotification(
          notificationAppLaunchDetails!.notificationResponse!);
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // RemoteNotificationService.onPressedNotificationInForeground(
        //     notificationResponse);
        await LocalNotificationUtils.handleOpenLocalNotification(
            notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      channelId, // id
      channelTitle, // title
      description: channelDescription, // description
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    requestPermissions();
  }

  static Future<bool> requestPermissions() async {
    try {
      bool notificationsEnabled = false;
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
      } else if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        notificationsEnabled =
            (await androidImplementation?.requestPermission())!;
      }
      return notificationsEnabled;
    } catch (error) {
      return false;
    }
  }

  static Future<void> configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static Future<List<int>> checkPendingNotificationRequests() async {
    List<int> listPendingNoti = [];
    List<PendingNotificationRequest> pendingNotificationRequests = [];
    try {
      pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (error) {
      Log.e("get pendingNotificationRequests $error");
    }
    for (var item in pendingNotificationRequests) {
      if (item.id > 0) {
        listPendingNoti.add(item.id);
      }
    }
    return listPendingNoti;
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // show notification right away
  static Future<void> showNotification(
      SendNotification sendNotification) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelId, channelTitle,
            channelDescription: channelDescription,
            styleInformation: BigTextStyleInformation(''),
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(sendNotification.id,
        sendNotification.title, sendNotification.body, notificationDetails,
        payload: sendNotification.payload);
  }

  // use when set schedule daily day of week, start from tomorrow notification
  static Future<void> scheduleDailyHourNotification(
      SendNotification sendNotification) async {
    for (var i = 1; i < 7; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          sendNotification.id + i,
          sendNotification.title,
          sendNotification.body,
          sendNotification.dayTime!.add(Duration(days: i)),
          payload: sendNotification.payload,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelTitle,
              channelDescription: channelDescription,
              styleInformation: BigTextStyleInformation(''),
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
    }
  }

  static Future<void> scheduleDayOfWeekAndTimeNotification(
      SendNotification sendNotification) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        sendNotification.id,
        sendNotification.title,
        sendNotification.body,
        sendNotification.dayTime!,
        payload: sendNotification.payload,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelTitle,
            channelDescription: channelDescription,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  // use when set schedule absolute time notification
  static Future<void> absoluteDateTimeNotification(
      SendNotification sendNotification) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        sendNotification.id,
        sendNotification.title,
        sendNotification.body,
        sendNotification.dayTime!,
        payload: sendNotification.payload,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelTitle,
            channelDescription: channelDescription,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static Future<void> zonedPendingDurationNotification(
      SendNotification sendNotification) async {
    if (sendNotification.dayTime == null) {
      return;
    }
    final pendingDuration = DateTimeUtils.secondBetween(
        tz.TZDateTime.now(tz.local), sendNotification.dayTime!);
    if (pendingDuration <= 0) {
      return;
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
        sendNotification.id,
        sendNotification.title,
        sendNotification.body,
        payload: sendNotification.payload,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: pendingDuration)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelTitle,
            channelDescription: channelDescription,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> scheduleMonthlyNotification(
      SendNotification sendNotification) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        sendNotification.id,
        sendNotification.title,
        sendNotification.body,
        sendNotification.dayTime!,
        payload: sendNotification.payload,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelTitle,
            channelDescription: channelDescription,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
  }

  static tz.TZDateTime nextInstanceOfTime(DateTime dayTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, dayTime.hour, dayTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
