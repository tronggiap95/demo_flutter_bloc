import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';

enum BatteryConnectionStatus {
  normal,
  low,
  charging;

  static BatteryConnectionStatus from(bool isCharging, int batteryLevel) {
    if (isCharging) {
      return BatteryConnectionStatus.charging;
    }

    if (batteryLevel <= 10) {
      return BatteryConnectionStatus.low;
    }

    return BatteryConnectionStatus.normal;
  }

  Color get textColor {
    switch (this) {
      case low:
        return ColorsApp.redBase;
      default:
        return ColorsApp.coalDarker;
    }
  }

  String get iconBaterry {
    switch (this) {
      case low:
        return ImagesApp.icBatteryLow;
      case charging:
        return ImagesApp.icBatteryCharging;
      default:
        return ImagesApp.icBatteryFull;
    }
  }

  String get getBaterryStr {
    switch (this) {
      case low:
        return StringsApp.lowBaterry;
      default:
        return StringsApp.battery;
    }
  }
}
