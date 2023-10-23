import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WidgetUtil {
  static Widget createRichText({
    required String value,
    required List<String> boldStrings,
    List<VoidCallback>? boldStringsCallback,
    TextStyle? normalTextStyle,
    TextStyle? boldTextStyle,
    TextAlign? textAlign,
  }) {
    var str = value;
    List<InlineSpan> richText = [];
    for (var i = 0; i < boldStrings.length; i++) {
      final splitArray = str.split(boldStrings[i]);
      richText.add(TextSpan(text: splitArray.first));
      richText.add(
        TextSpan(
          recognizer: TapGestureRecognizer()..onTap = boldStringsCallback?[i],
          text: boldStrings[i],
          style: boldTextStyle ??
              TextStylesApp.medium(
                color: ColorsApp.coalDarkest,
                fontSize: FontSizeApp.s16,
              ),
        ),
      );

      if (i + 1 >= boldStrings.length) {
        richText.add(TextSpan(text: splitArray.last));
      }

      str = splitArray.last;
    }
    if (richText.isEmpty) {
      richText.add(TextSpan(text: value));
    }
    final context = NavigationApp.navigatorKey.currentContext!;
    return RichText(
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textAlign: textAlign ?? TextAlign.center,
      text: TextSpan(
        style: normalTextStyle ??
            TextStylesApp.regular(
              color: ColorsApp.coalDarkest,
              fontSize: FontSizeApp.s16,
            ),
        children: richText.toList(),
      ),
    );
  }
}
