import 'package:flutter/material.dart';

class DashSeparator extends StatelessWidget {
  const DashSeparator({
    Key? key,
    this.height = 1,
    this.color = Colors.black,
    this.dashWidth = 2.0,
    this.axis = Axis.horizontal,
  }) : super(key: key);
  final double height;
  final Color color;
  final double dashWidth;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = axis == Axis.horizontal
            ? constraints.constrainWidth()
            : constraints.constrainHeight();
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: axis == Axis.horizontal ? dashWidth : dashHeight,
              height: axis == Axis.horizontal ? dashHeight : dashWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: axis,
        );
      },
    );
  }
}
