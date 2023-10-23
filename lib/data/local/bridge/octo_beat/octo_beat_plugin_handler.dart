import 'package:octo360/application/utils/logger/logger.dart';
import 'package:octo360/data/di/di.dart';
import 'package:octo360/data/local/bridge/octo_beat/handler/octo_beat_symtoms_trigger_handler.dart';
import 'package:octo360/data/local/notification/local_notification_services.dart';
import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
void octoBeatHeadlessTask() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const MethodChannel backgroundChannel = MethodChannel(
      'com.octo.octo_beat_plugin.plugin.service/octo_headless_task/event');

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  backgroundChannel.setMethodCallHandler((MethodCall call) async {
    final args = call.arguments;
    final method = call.method;
    final data = OctoBeatData(event: OctoBeatEvent.from(method), data: args);
    Log.d(
        "HeadLess task: args: ${data.event.name}, method: ${data.data.toString()}");
    //Handle headless tasks
    //Isolate cannot share data with any other threads and maint thread as well.
    //should init all modules
    await initModulesInIsolateTasks();

    switch (data.event) {
      case OctoBeatEvent.mctTrigger:
        int evTime = data.data['mctEventTime'];
        if (evTime != 0) {
          OctoBeatSymtomsTriggerHandler.showLocalNotif(evTime);
        }
        break;
      default:
        break;
    }
  });

  // 4. Alert plugin that the callback handler is ready for events.
  backgroundChannel
      .invokeMethod('octo_beat_plugin.octo_headless_task.initialized');
}

Future<void> initModulesInIsolateTasks() async {
  try {
    if (isModuleRegistered()) {
      return;
    }
    try {
      initModule();
    } catch (error) {
      Log.e("initModule $error");
    }
    try {
      await LocalNotificationServices.init();
    } catch (error) {
      Log.e("initModule $error");
    }
  } catch (error) {
    Log.e("$error");
  }
}
