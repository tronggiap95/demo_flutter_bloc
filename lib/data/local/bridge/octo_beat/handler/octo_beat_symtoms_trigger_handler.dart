import 'dart:async';
import 'dart:convert';

import 'package:octo360/application/constants/octobeat_symptoms_snapshot_static_data.dart';
import 'package:octo360/application/enum/app_lifecycle_state_enum.dart';
import 'package:octo360/application/enum/notification_enum.dart';
import 'package:octo360/application/utils/lcoal_notification_utils/local_notification_utils.dart';
import 'package:octo360/data/local/bridge/octo_beat/handler/octo_beat_symtoms_trigger_model/octo_beat_symtoms_trigger_model.dart';
import 'package:octo360/data/local/notification/local_notification_modal/local_notification_modal.dart';
import 'package:octo360/data/local/notification/local_notification_services.dart';
import 'package:octo360/data/local/share_pref/shared_pref.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/providers/home/home_provider.dart';
import 'package:octo360/presentation/widgets/snack_bar/custom_snackar/custom_snackbar.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/values/values_manager.dart';
import 'package:octo_beat_plugin/octo_beat_plugin.dart';
import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class OctoBeatSymtomsTriggerHandler {
  static StreamSubscription? start(context) {
    return OctoBeatPlugin.listenEvent().listen((OctoBeatData? event) async {
      if (event == null) return;
      if (event.event == OctoBeatEvent.mctTrigger) {
        int evTime = event.data['mctEventTime'];
        if (evTime != 0) {
          final appState = await SharedPref.getAppLifecycleState();
          switch (appState) {
            case AppLifecycleStateEnum.active:
              openBottomSheetOctoBeatSymptomsSnapshot(
                evTime,
                OctoBeatSymptomsSnapshotStaticData.defaultCountdownTime,
              );
              break;
            case AppLifecycleStateEnum.inactive:
              showLocalNotif(evTime);
              break;
            default:
          }
        }
      }
    });
  }

  static Future<void> showLocalNotif(int evTime) async {
    final now = DateTime.now();
    final dataPayload = jsonEncode(
        OctoBeatSymptomsSnapshot(evTime: evTime, timeTrigger: now).toJson());
    final idNotification = LocalNotificationUtils.formatIdNotification(
        tz.TZDateTime.now(tz.local),
        false,
        LocalNotificationType.octoBeatSymptomsTrigger);
    final payload = Payload(
      scheduleTime: now,
      data: dataPayload,
      localNotificationType: LocalNotificationType.octoBeatSymptomsTrigger,
    );
    final String stringPayload = jsonEncode(payload.toJson());
    final bodyContent = StringsApp.manualEventTriggered;
    final sendNotification = SendNotification(
      id: idNotification,
      title: null,
      isRepeat: false,
      body: bodyContent,
      payload: stringPayload,
    );
    await LocalNotificationServices.showNotification(sendNotification);
  }

  static Future<void> handleOpenOctoBeatSymptomsNotif(
      BuildContext context, String dataPayload) async {
    final octoBeatSymptomsSnapshot =
        OctoBeatSymptomsSnapshot.fromJson(jsonDecode(dataPayload));
    final evTime = octoBeatSymptomsSnapshot.evTime;
    final timeTrigger = octoBeatSymptomsSnapshot.timeTrigger;
    DateTime timeStamp = timeTrigger.add(const Duration(
        seconds: OctoBeatSymptomsSnapshotStaticData.defaultCountdownTime));
    final now = DateTime.now();
    final secondBetween = timeStamp.difference(now).inSeconds;
    const bufferTime = OctoBeatSymptomsSnapshotStaticData.defaultCountdownTime;
    final isConnectedDevice = await isConnectDevice();
    if (isConnectedDevice) {
      Future.delayed(Duration.zero, () {
        if (secondBetween >= 5 && secondBetween <= bufferTime) {
          openBottomSheetOctoBeatSymptomsSnapshot(evTime, secondBetween);
        } else {
          CustomSnackBar.displaySnackBar(
            context: context,
            message: StringsApp.sessionIsExpired,
            imagePath: ImagesApp.icSnackbarWarning,
            marginBottom: MarginApp.m24,
          );
        }
      });
    }
  }

  static Future<bool> isConnectDevice() async {
    final device = await OctoBeatPlugin.getDeviceInfo();
    return device != null && device.isConnected;
  }

  static Future<void> openBottomSheetOctoBeatSymptomsSnapshot(
      int evTime, int remainingTime) async {
    final context = NavigationApp.navigatorKey.currentContext;
    if (context == null) return;
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => FractionallySizedBox(
              heightFactor: 0.6,
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: octoBeatSymptomsTriggerProvider(evTime, remainingTime)),
            ),
        isScrollControlled: true,
        barrierColor: Colors.black.withOpacity(OpacityApp.opa60),
        enableDrag: false,
        isDismissible: false);
  }
}
