import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class LblError extends StatelessWidget {
  final String errText;
  const LblError({
    Key? key,
    required this.errText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: PaddingApp.p6),
            child: SvgPicture.asset(ImagesApp.icError),
          ),
          const SizedBox(width: SizeApp.s4),
          Flexible(
            child: Text(
              errText,
              style: TextStylesApp.semiBold(
                  color: ColorsApp.redBase,
                  fontSize: SizeApp.s12,
                  lineHeight: SizeApp.s22),
            ),
          ),
        ]);
  }
}
