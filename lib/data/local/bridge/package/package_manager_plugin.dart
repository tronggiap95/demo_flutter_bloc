import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:octo360/application/enum/platform/platform_type_enum.dart';

enum ScreenOrientationIOS {
  portrait,
  portraitUpsideDown,
  landscapeLeft,
  landscapeRight;

  ///0: portrait
  ///1: portraitUpsideDown
  ///2: landscapeLeft
  ///3: landscapeRight
  int get value {
    switch (this) {
      case ScreenOrientationIOS.portrait:
        return 0;
      case ScreenOrientationIOS.portraitUpsideDown:
        return 1;
      case ScreenOrientationIOS.landscapeLeft:
        return 2;
      case ScreenOrientationIOS.landscapeRight:
        return 3;
    }
  }
}

class PackageManagerPlugin {
  static final _deviceInfo = DeviceInfoPlugin();
  static const _platform =
      MethodChannel('com.octomed.octo360.package_manager.method_channel');

  //Android only
  static Future<bool> getPackageInfo(String package) async {
    try {
      final result = await _platform.invokeMethod('getPackageInfo', [package]);
      return Future.value(result as bool);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<String> getAppVersion() async {
    try {
      final result = await _platform.invokeMethod('getAppVersion');
      return Future.value(result as String);
    } catch (error) {
      return Future.value('');
    }
  }

  static Future<bool> openBlueSetting() async {
    try {
      if (Platform.isAndroid) {
        AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
        return true;
      }
      final result = await _platform.invokeMethod('openGeneralSetting');
      return Future.value(result);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<bool> openWifiSetting() async {
    try {
      if (Platform.isAndroid) {
        AppSettings.openAppSettings(type: AppSettingsType.wifi);
        return true;
      }
      final result = await _platform.invokeMethod('openGeneralSetting');
      return Future.value(result);
    } catch (error) {
      return Future.value(false);
    }
  }

  static Future<String?> getDeviceId() async {
    final deviceId = Platform.isAndroid
        ? (await _deviceInfo.androidInfo).id
        : (await _deviceInfo.iosInfo).identifierForVendor;
    return deviceId;
  }

  static Future<int?> getAndroidVersion() async {
    final sdkVersion = (await _deviceInfo.androidInfo);
    return int.tryParse(sdkVersion.version.release ?? "0");
  }

  static Future<String?> getDeviceModel() async {
    final model = Platform.isAndroid
        ? (await _deviceInfo.androidInfo).model
        : (await _deviceInfo.iosInfo).utsname.machine;
    return model;
  }

  static Future<String?> getDeviceBrand() async {
    final brand = Platform.isAndroid
        ? (await _deviceInfo.androidInfo).brand
        : (await _deviceInfo.iosInfo).model;
    return brand;
  }

  static Future<String?> getDeviceVersion() async {
    final version = Platform.isAndroid
        ? (await _deviceInfo.androidInfo).version.release
        : (await _deviceInfo.iosInfo).systemVersion;
    return version;
  }

  static Future<String> getPlatform() async {
    return Platform.isAndroid
        ? PlatformTypeEnum.android.value
        : PlatformTypeEnum.ios.value;
  }

  static void setScreenOrienttation(ScreenOrientationIOS orientation) async {
    if (Platform.isAndroid) {
      return;
    }

    await _platform.invokeMethod('setScreenOrientation', [orientation.value]);
  }

  static void enableScreenRotation() {
    if (Platform.isIOS) {
      setScreenOrienttation(ScreenOrientationIOS.landscapeLeft);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  static void portraitModeOnly() {
    if (Platform.isIOS) {
      setScreenOrienttation(ScreenOrientationIOS.portrait);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }
}
