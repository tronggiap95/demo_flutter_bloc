import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctobeatConnectingDeviceDialog extends StatelessWidget {
  final String? deviceName;
  const OctobeatConnectingDeviceDialog({
    Key? key,
    this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(
        vertical: PaddingApp.p16,
        horizontal: PaddingApp.p14,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            BorderRadiusApp.r16,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            width: 180,
            height: 160,
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: ColorsApp.primaryBase,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: MarginApp.m16),
            child: Text(
              StringsApp.connectingToOctobeatPleaseWait,
              style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest,
                fontSize: FontSizeApp.s16,
                lineHeight: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
