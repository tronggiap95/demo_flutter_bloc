import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SizeApp.s100,
                    minHeight: SizeApp.s120,
                  ),
                  child: Transform.scale(
                    scale: 2.8,
                    child: Lottie.asset(
                      ImagesApp.loadingDialogAnimation,
                      frameRate: FrameRate.max,
                    ),
                  ),
                ),
                Text(
                  StringsApp.pleaseWait,
                  style: TextStylesApp.medium(color: ColorsApp.coalDarkest),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
