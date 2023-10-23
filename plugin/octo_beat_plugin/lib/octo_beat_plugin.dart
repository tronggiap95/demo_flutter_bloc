import 'dart:async';

import 'package:octo_beat_plugin/model/octo_beat_data.dart';
import 'package:octo_beat_plugin/model/octo_beat_device.dart';
import 'package:flutter/services.dart';

class OctoBeatPlugin {
  static final listeners = StreamController<OctoBeatData>.broadcast();

  static const MethodChannel _methodChannel = MethodChannel('octo_beat_plugin');
  static const _eventChannel =
      EventChannel("com.octo.octo_beat_plugin.plugin.event/event");

  static Stream<OctoBeatData> listenEvent() {
    return listeners.stream;
  }

  static StreamSubscription subscribeEvents() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      try {
        return OctoBeatData.fromMap(event);
      } catch (error) {
        return null;
      }
    }).listen((event) {
      if (event == null) return;
      listeners.add(event);
    });
  }

  //Get octo_beat device information
  static Future<OctoBeatDevice?> getDeviceInfo({MethodChannel? channel}) async {
    try {
      final result =
          await (channel ?? _methodChannel).invokeMethod('getDeviceInfo');
      return Future.value(OctoBeatDevice.fromMap(result));
    } catch (error) {
      return Future.value(null);
    }
  }

  //@params: array of int [1, 2 ,3 ,4 ,5]
  static Future<bool> submitMctEvent(
      {required int evTime, required List<int> symptoms}) async {
    try {
      final result = await _methodChannel
          .invokeMethod('submitMctEvent', [evTime, symptoms]);
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }
}
