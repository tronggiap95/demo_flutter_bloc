import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_event.dart';
import 'package:flutter/services.dart';

class AndroidHeadlessTask {
  //FOR ANDROID ONLY - USING TO HANDLE ISOLATE TASK - INCLUDE APP KILLED TASKS
  static Future<dynamic> handleAndroidHeadlessTask(
      {required String method,
      required dynamic args,
      required MethodChannel channel}) async {
    final data = OctoBeatData(event: OctoBeatEvent.from(method), data: args);
    switch (data.event) {
      case OctoBeatEvent.updateInfo:
      case OctoBeatEvent.mctTrigger:
      // return await OctoBeatEventHandler.handleHeadlessTasks(
      //     channel: channel, data: data);
      default:
        return null;
    }
  }
}
