import 'dart:async';

import 'package:octo_beat_plugin/connection/octo_beat_connection_data.dart';
import 'package:octo_beat_plugin/connection/octo_beat_connection_event.dart';
import 'package:octo_beat_plugin/model/octo_task.dart';
import 'package:flutter/services.dart';

class OctoBeatConnectionPlugin {
  static const _methodChannel =
      MethodChannel('com.octo.octo_beat_plugin.plugin.connection/method');
  static const _eventChannel =
      EventChannel("com.octo.octo_beat_plugin.plugin.connection/event");

  static Stream<OctoBeatConnectionData?> listenEvent() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      try {
        final octoTask = OctoTask.fromMap(event);
        return OctoBeatConnectionData(
            event: OctoBeatConnectionEvent.from(octoTask.event),
            data: octoTask.data);
      } catch (error) {
        return null;
      }
    });
  }

  static Future<bool> startScan() async {
    try {
      final result = await _methodChannel.invokeMethod('startScan');
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<bool> stopScan() async {
    try {
      final result = await _methodChannel.invokeMethod('stopScan');
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<bool> connect(String address) async {
    try {
      final result = await _methodChannel.invokeMethod('connect', [address]);
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<bool> deleteDevice() async {
    try {
      final result = await _methodChannel.invokeMethod('deleteDevice');
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }
}
