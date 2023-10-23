import 'dart:io';

import 'package:octo360/src/values/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomSheetUtil {
  static void showFullScreenBottomSheet(
      {required BuildContext context,
      required Widget Function(BuildContext) builder}) {
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        duration: DurationsApp.bottomSheetFullScreenDuration,
        animationCurve: Curves.easeOut,
        enableDrag: false,
        context: context,
        topRadius: const Radius.circular(BorderRadiusApp.r16),
        builder: builder,
        isDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    } else {
      showMaterialModalBottomSheet(
        duration: DurationsApp.bottomSheetFullScreenDuration,
        animationCurve: Curves.easeOut,
        expand: true,
        enableDrag: false,
        context: context,
        builder: builder,
        isDismissible: false,
      );
    }
  }
}
