import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OutlinedButtonApp extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool hasBorder;
  double? borderWidth;
  final Color? colorText;
  final Color? borderColor;
  final Color? bgColor;
  final double? fontSizeText;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? paddingButton;
  bool isLoading;
  OutlinedButtonApp({
    Key? key,
    this.onPressed,
    required this.label,
    this.hasBorder = true,
    this.colorText,
    this.borderWidth,
    this.borderColor,
    this.bgColor,
    this.fontSizeText,
    this.labelStyle,
    this.paddingButton,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: !hasBorder
            ? const BorderSide(color: Colors.transparent)
            : BorderSide(
                width: borderWidth ?? (isLoading ? 1 : 2),
                color: borderColor ??
                    (isLoading
                        ? ColorsApp.coalLighter
                        : ColorsApp.primaryLight),
              ),
        backgroundColor: bgColor ?? ColorsApp.white,
        padding: paddingButton,
      ),
      child: isLoading
          ? Container(
              width: SizeApp.s24,
              height: SizeApp.s24,
              padding: const EdgeInsets.all(PaddingApp.p2),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorsApp.primaryLight,
              ),
            )
          : Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: labelStyle ??
                  TextStylesApp.bold(
                    color: colorText ?? ColorsApp.primaryBase,
                    fontSize: fontSizeText ?? FontSizeApp.s16,
                  ),
            ),
    );
  }
}
