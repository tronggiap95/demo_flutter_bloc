import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';

class OctoBeatServicePlugin {
  static const _methodChannel =
      MethodChannel("com.octo.octo_beat_plugin.plugin.service/method");

  ///Android only
  static Future<bool> startService() async {
    try {
      if (Platform.isIOS) {
        return false;
      }

      final result = await _methodChannel.invokeMethod('startService');
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  ///Android only
  static Future<bool> stopService() async {
    try {
      if (Platform.isIOS) {
        return false;
      }

      final result = await _methodChannel.invokeMethod('stopService');
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  //Android only
  static Future<bool> initializeHeadlessService(
      Function headlessCallback) async {
    try {
      if (Platform.isIOS) {
        return false;
      }

      final callback = PluginUtilities.getCallbackHandle(headlessCallback);

      if (callback == null) {
        return false;
      }

      final result = await _methodChannel
          .invokeMethod('initializeHeadlessService', [callback.toRawHandle()]);

      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }
}
