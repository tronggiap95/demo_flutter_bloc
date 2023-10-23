import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class TimeCell extends StatelessWidget {
  const TimeCell({
    super.key,
    required this.value,
    required this.unit,
    required this.bgImage,
  });
  final String value;
  final String unit;
  final String bgImage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(bgImage),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  value,
                  style: TextStylesApp.bold(
                    color: ColorsApp.coalDarkest,
                    fontSize: FontSizeApp.s30,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: MarginApp.m8),
            child: Text(
              unit,
              style: TextStylesApp.regular(
                color: ColorsApp.coalDark,
                fontSize: FontSizeApp.s16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
