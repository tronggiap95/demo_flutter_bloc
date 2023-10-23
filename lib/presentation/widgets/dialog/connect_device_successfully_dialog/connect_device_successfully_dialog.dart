import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class ConnectDeviceSuccessfullyDialog extends StatelessWidget {
  final String imagePath;
  final String headerTitle;
  final String? deviceName;
  final String? deviceInfo;

  const ConnectDeviceSuccessfullyDialog({
    Key? key,
    required this.imagePath,
    required this.headerTitle,
    this.deviceName,
    this.deviceInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(
        vertical: PaddingApp.p16,
        horizontal: 0,
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
          Image.asset(
            imagePath,
            height: SizeApp.s160,
            width: SizeApp.s180,
          ),
          Container(
            margin: const EdgeInsets.only(top: MarginApp.m32),
            child: Text(
              headerTitle,
              style: TextStylesApp.medium(color: ColorsApp.coalDarkest),
            ),
          ),
          if (deviceName != null)
            Container(
              margin: const EdgeInsets.only(top: MarginApp.m8),
              child: Text(
                deviceName!,
                style: TextStylesApp.bold(
                  color: ColorsApp.coalDarker,
                  fontSize: FontSizeApp.s22,
                ),
              ),
            ),
          deviceInfo != null
              ? Container(
                  margin: const EdgeInsets.only(top: MarginApp.m8),
                  child: Text(
                    deviceInfo!,
                    style: TextStylesApp.regular(
                        color: ColorsApp.coalDarker, fontSize: FontSizeApp.s14),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
