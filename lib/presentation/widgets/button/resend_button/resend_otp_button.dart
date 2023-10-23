import 'package:flutter/material.dart';

import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';

class ResendOtpButton extends StatelessWidget {
  final VoidCallback onPressedSendOtp;
  final int countTime;
  const ResendOtpButton({
    Key? key,
    required this.onPressedSendOtp,
    required this.countTime,
  }) : super(key: key);

  void _onPressSend() {
    onPressedSendOtp.call();
  }

  bool isEnable() {
    return countTime == 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: isEnable() ? _onPressSend : null, child: _renderText());
  }

  Widget _renderText() {
    if (isEnable()) {
      return Text(
        StringsApp.resendRightAway,
        style: TextStylesApp.medium(
            color: ColorsApp.primaryBase, fontSize: FontSizeApp.s14),
      );
    }
    return Text(
      StringsApp.resendAfterSecond
          .replaceAll(StringsApp.replaceValue, countTime.toString()),
      style: TextStylesApp.medium(
          color: ColorsApp.primaryLight, fontSize: FontSizeApp.s14),
    );
  }
}
