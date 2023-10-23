import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class GuideSnackBar extends StatelessWidget {
  final String? icon;
  final String message;
  final String tilteButton;
  final VoidCallback? onTap;
  final double marginBottom;

  const GuideSnackBar({
    Key? key,
    required this.message,
    required this.tilteButton,
    this.onTap,
    this.icon,
    this.marginBottom = MarginApp.m16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: marginBottom,
      left: MarginApp.m16,
      right: MarginApp.m16,
      child: Container(
        padding: const EdgeInsets.all(PaddingApp.p12),
        decoration: BoxDecoration(
          color: ColorsApp.coalDarkest,
          borderRadius: const BorderRadius.all(
            Radius.circular(BorderRadiusApp.r8),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(icon ?? ImagesApp.icSnackbarWarning),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: MarginApp.m8),
                child: Text(
                  message,
                  style: TextStylesApp.regular(
                      color: ColorsApp.white, fontSize: FontSizeApp.s14),
                ),
              ),
            ),
            if (onTap != null)
              InkWell(
                onTap: onTap,
                child: Text(
                  tilteButton,
                  style: TextStylesApp.bold(
                    color: ColorsApp.primaryBase,
                    fontSize: FontSizeApp.s14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
