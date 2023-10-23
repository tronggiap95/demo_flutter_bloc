import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';

enum ElectrodesStatus {
  none,
  connected,
  disconnected;

  static ElectrodesStatus from(bool? status) {
    switch (status) {
      case true:
        return connected;
      case false:
        return disconnected;
      default:
        return none;
    }
  }

  String get value {
    switch (this) {
      case connected:
        return StringsApp.goodContact;
      case disconnected:
        return StringsApp.partialContact;
      default:
        return StringsApp.electrodes;
    }
  }

  Color get textColor {
    switch (this) {
      default:
        return ColorsApp.coalDarkest;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case connected:
        return ColorsApp.greenLightest;
      case disconnected:
        return ColorsApp.orangeLightest;
      default:
        return Colors.transparent;
    }
  }

  String get icon {
    switch (this) {
      case connected:
        return ImagesApp.icSuccessSync;
      case disconnected:
        return ImagesApp.icWarningTriangle;
      default:
        return ImagesApp.icWarningTriangle;
    }
  }

  Color get iconColor {
    switch (this) {
      case connected:
        return ColorsApp.greenBase;
      case disconnected:
        return ColorsApp.orangeBase;
      default:
        return ColorsApp.coalDarkest;
    }
  }
}
