import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

import '../../../../src/colors/colors_app.dart';

class WarningChip extends StatelessWidget {
  final String? icon;
  final Color? iconColor;
  final String title;
  final Color? bgColor;
  final Color? textColor;
  final double? borderRadius;
  final double? iconSize;
  final double? textSize;
  final bool hasIcon;
  const WarningChip({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.bgColor,
    this.textColor,
    this.borderRadius = BorderRadiusApp.r16,
    this.iconSize,
    this.textSize,
    this.hasIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PaddingApp.p6, vertical: PaddingApp.p5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius!)),
        color: bgColor ?? ColorsApp.greenLightest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon)
            SvgPicture.asset(
              icon ?? ImagesApp.icWarning,
              color: iconColor,
              width: iconSize ?? SizeApp.s20,
              height: iconSize ?? SizeApp.s20,
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: MarginApp.m4),
              child: Text(
                title,
                style: TextStylesApp.medium(
                  color: textColor ?? ColorsApp.coalDarkest,
                  fontSize: textSize ?? FontSizeApp.s14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
