import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/presentation/widgets/shadowBox/container_with_shadow/container_with_shadow.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class SelectCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool hasShadow;
  final bool hasBorder;
  final double borderRadius;
  final double containerPadding;
  final double iconPaddingRight;

  final Widget? leftIcon;
  final Color? textColor;
  final Color? iconColor;
  final Color? bgColor;
  final bool isEnable;

  const SelectCard({
    Key? key,
    required this.title,
    required this.onTap,
    this.leftIcon,
    this.textColor,
    this.iconColor,
    this.bgColor,
    this.hasBorder = true,
    this.hasShadow = true,
    this.borderRadius = BorderRadiusApp.r8,
    this.containerPadding = PaddingApp.p16,
    this.iconPaddingRight = PaddingApp.p0,
    this.isEnable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContainerWithShadow(
      shadowColor: hasShadow ? null : Colors.transparent,
      child: Card(
        color: bgColor,
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: hasBorder
              ? BorderSide(color: ColorsApp.coalLightest)
              : BorderSide.none,
        ),
        elevation: ElevationApp.ev0,
        child: InkWell(
          onTap: isEnable ? onTap : null,
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftIcon != null) leftIcon!,
                Expanded(
                  child: Text(
                    title,
                    style: TextStylesApp.medium(
                      color: textColor ?? ColorsApp.coalDarkest,
                      fontSize: FontSizeApp.s16,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: iconPaddingRight),
                  child: SvgPicture.asset(
                    ImagesApp.icCaret,
                    color: iconColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
