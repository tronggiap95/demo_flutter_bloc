import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:octo360/application/utils/string/string_utils.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

// ignore: must_be_immutable
class SquareCheckBox extends StatefulWidget {
  final String? sublabel;
  final String label;
  final bool? checkBoxIsAfter;
  final TextStyle? selectedTextStyle;
  bool? value;
  final void Function(bool value) onValueChanged;

  SquareCheckBox({
    Key? key,
    required this.label,
    this.checkBoxIsAfter = false,
    this.sublabel = '',
    this.value = false,
    required this.onValueChanged,
    this.selectedTextStyle,
  }) : super(key: key);

  @override
  State<SquareCheckBox> createState() => _SquareCheckBoxState();
}

class _SquareCheckBoxState extends State<SquareCheckBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.value = !widget.value!;
        });
        widget.onValueChanged(widget.value!);
      },
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeApp.s8),
          child: !widget.checkBoxIsAfter!
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: PaddingApp.p4),
                      child: SvgPicture.asset(
                        !widget.value!
                            ? ImagesApp.icSquareCheckbox
                            : ImagesApp.icSquareCheckboxFill,
                      ),
                    ),
                    const SizedBox(width: SizeApp.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label,
                            style: !widget.value!
                                ? TextStylesApp.regular(
                                    color: ColorsApp.coalDarkest,
                                    fontSize: FontSizeApp.s16,
                                  )
                                : widget.selectedTextStyle ??
                                    TextStylesApp.bold(
                                      color: ColorsApp.coalDarkest,
                                      fontSize: FontSizeApp.s16,
                                    ),
                          ),
                          StringUtils.isNotNullOrEmpty(widget.sublabel)
                              ? Text(
                                  widget.sublabel ?? '',
                                  style: TextStylesApp.regular(
                                    color: ColorsApp.coalDark,
                                    fontSize: FontSizeApp.s14,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label,
                            style: !widget.value!
                                ? TextStylesApp.regular(
                                    color: ColorsApp.coalDarkest,
                                    fontSize: FontSizeApp.s16,
                                  )
                                : widget.selectedTextStyle ??
                                    TextStylesApp.bold(
                                      color: ColorsApp.coalDarkest,
                                      fontSize: FontSizeApp.s16,
                                    ),
                          ),
                          StringUtils.isNotNullOrEmpty(widget.sublabel)
                              ? Text(
                                  widget.sublabel ?? '',
                                  style: TextStylesApp.regular(
                                    color: ColorsApp.coalDark,
                                    fontSize: FontSizeApp.s14,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(width: SizeApp.s12),
                    Padding(
                      padding: const EdgeInsets.only(top: PaddingApp.p4),
                      child: SvgPicture.asset(
                        !widget.value!
                            ? ImagesApp.icSquareCheckbox
                            : ImagesApp.icSquareCheckboxFill,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
