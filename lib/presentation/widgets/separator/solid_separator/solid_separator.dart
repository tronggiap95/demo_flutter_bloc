import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';

class SolidSeparator extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;

  const SolidSeparator({
    Key? key,
    this.height = 1,
    this.width = double.infinity,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color ?? ColorsApp.primaryLightest,
    );
  }
}
