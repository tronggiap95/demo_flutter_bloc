import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class CustomSnackBar {
  static var isSnackBarActive = false;

  static hideSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static displaySnackBar({
    required BuildContext context,
    required String message,
    required String imagePath,
    Function? customAction,
    String? customActionLabel,
    Color? customActionLabelColor,
    Duration duration = const Duration(seconds: 3),
    double marginBottom = 0,
  }) {
    isSnackBarActive = true;
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BorderRadiusApp.r8),
            ),
            margin: EdgeInsets.only(
              left: SizeApp.s16,
              right: SizeApp.s16,
              bottom: marginBottom,
            ),
            padding: const EdgeInsets.all(0.0), // remove default padding
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorsApp.coalDarkest,
            duration: duration,
            // wrap content with "WillPopScope" to remove snackbar when the user presses back button (Android)
            content: WillPopScope(
              onWillPop: () async {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                return true;
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SizeApp.s12,
                      SizeApp.s12,
                      SizeApp.s8,
                      SizeApp.s12,
                    ),
                    child: SvgPicture.asset(imagePath),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        message,
                        style: TextStylesApp.regular(
                          color: ColorsApp.white,
                          fontSize: FontSizeApp.s14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            action: customAction != null
                ? SnackBarAction(
                    label: customActionLabel as String,
                    textColor: customActionLabelColor ?? ColorsApp.white,
                    onPressed: () {
                      customAction();
                    },
                  )
                : null,
          ),
        )
        .closed
        .then((value) => isSnackBarActive = false);
  }
}
