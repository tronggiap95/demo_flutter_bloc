import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class UnorderedListText extends StatelessWidget {
  final List<Widget> texts;
  final String? customDotPath;
  const UnorderedListText({
    required this.texts,
    this.customDotPath = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      widgetList.add(
        customDotPath == ''
            ? UnorderedListItem(text: text)
            : UnorderedListItemCustomDot(
                text: text, customDotPath: customDotPath!),
      );
    }
    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  final Widget text;
  const UnorderedListItem({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "  •  ",
          style: TextStylesApp.medium(
            color: ColorsApp.coalDarkest,
            fontSize: FontSizeApp.s14,
          ).copyWith(height: 22 / 14),
        ),
        Expanded(
          child: text,
        ),
      ],
    );
  }
}

class UnorderedListItemCustomDot extends StatelessWidget {
  final Widget text;
  final String customDotPath;
  const UnorderedListItemCustomDot({
    required this.text,
    required this.customDotPath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PaddingApp.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: PaddingApp.p8),
            child: SvgPicture.asset(customDotPath),
          ),
          const SizedBox(width: SizeApp.s8),
          Expanded(
            child: text,
          ),
        ],
      ),
    );
  }
}
