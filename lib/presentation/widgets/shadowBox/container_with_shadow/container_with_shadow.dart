import 'package:flutter/material.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class ContainerWithShadow extends StatelessWidget {
  final Widget child;
  final Color? shadowColor;
  final Offset shadowXY;
  final double shadowB;
  final double shadowS;
  const ContainerWithShadow({
    Key? key,
    required this.child,
    this.shadowColor,
    this.shadowXY = OffsetApp.o04,
    this.shadowB = BlurRadiusApp.b10,
    this.shadowS = SpreadRadiusApp.s0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? ColorsApp.shadowColor,
            offset: shadowXY,
            blurRadius: shadowB,
            spreadRadius: shadowS,
          ),
        ],
      ),
      child: child,
    );
  }
}
