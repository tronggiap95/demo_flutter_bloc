import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class FilledButtonApp extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final Color? textColorDisable;
  final VoidCallback? onPressed;
  final bool isEnable;
  final bool hasShadow;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? paddingButton;

  const FilledButtonApp({
    super.key,
    required this.label,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.textColorDisable,
    this.onPressed,
    this.isEnable = true,
    this.hasShadow = true,
    this.labelStyle,
    this.paddingButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnable ? onPressed : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: ColorsApp.primaryLightest,
        backgroundColor: color ?? ColorsApp.primaryBase,
        textStyle: labelStyle,
        padding: paddingButton,
      ),
      child: isLoading
          ? Container(
              width: SizeApp.s24,
              height: SizeApp.s24,
              padding: const EdgeInsets.all(PaddingApp.p2),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorsApp.white,
              ),
            )
          : Text(
              label,
              style: TextStyle(
                color: textColor ??
                    (isEnable ? ColorsApp.white : ColorsApp.primaryLighter),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
    );
  }
}
