import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/presentation/widgets/input/input_text_field/phone_number_formatter_ext.dart';
import 'package:octo360/presentation/widgets/input/input_text_field/upper_case_text_formatter_ext.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class InputTextFieldApp extends StatelessWidget {
  final String? label;
  final double? labelSize;
  final String? hint;
  final String? errorText;
  final String? prefixIcon;
  final TextInputAction textInputAction;
  final Function(String?)? onChanged;
  final ValueChanged<String>? onSubmit;
  final bool enabled;
  final TextInputType keyboardType;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputFormatter? textInputFormatter;
  final bool isRequired;
  final VoidCallback? onTap;
  final bool hasBorder;

  final bool shouldCapEachWord;
  const InputTextFieldApp({
    Key? key,
    this.label,
    this.hint,
    this.labelSize = FontSizeApp.s14,
    this.errorText,
    this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmit,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.controller,
    this.textInputFormatter,
    this.isRequired = false,
    this.onTap,
    this.hasBorder = true,
    this.shouldCapEachWord = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _renderLabel(context),
        Stack(
          children: [
            _TextFormField(
              initialValue: initialValue,
              hint: hint,
              errorText: errorText,
              prefixIcon: prefixIcon,
              textInputAction: textInputAction,
              onChanged: onChanged,
              onFieldSubmitted: onSubmit,
              enabled: enabled,
              keyboardType: keyboardType,
              controller: controller,
              textInputFormatter: textInputFormatter,
              onTap: onTap,
              hasBorder: hasBorder,
              shouldCapEachWord: shouldCapEachWord,
            ),
            errorText?.isNotEmpty == true
                ? Container(
                    margin: const EdgeInsets.only(top: MarginApp.m52),
                    child: _renderLblError(
                      errText: errorText!,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  Container _renderLabel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MarginApp.m8),
      child: RichText(
        textAlign: TextAlign.start,
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          text: label,
          style: TextStylesApp.regular(
              color: ColorsApp.coalDarker, fontSize: labelSize!),
          children: isRequired
              ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: ColorsApp.redBase,
                      fontSize: labelSize,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _renderLblError({required String errText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: PaddingApp.p4),
          child: SvgPicture.asset(ImagesApp.icError),
        ),
        const SizedBox(width: SizeApp.s4),
        Flexible(
          child: Text(
            errText,
            style: TextStylesApp.regular(
              color: ColorsApp.redBase,
              fontSize: SizeApp.s14,
              lineHeight: SizeApp.s22,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextFormField extends StatelessWidget {
  _TextFormField({
    Key? key,
    required this.initialValue,
    required this.errorText,
    required this.prefixIcon,
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.hasBorder,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.controller,
    this.textInputFormatter,
    this.onTap,
    this.hint,
    this.shouldCapEachWord,
  }) : super(key: key);

  final String? initialValue;
  final String? hint;
  final String? errorText;
  final String? prefixIcon;
  final TextInputAction textInputAction;
  final Function(String? p1)? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final TextInputFormatter? textInputFormatter;
  final VoidCallback? onTap;
  final bool hasBorder;
  final bool? shouldCapEachWord;

  List<TextInputFormatter>? _createInputFormatter() {
    final List<TextInputFormatter> inputFormatter = [];
    if (shouldCapEachWord == true) {
      inputFormatter.add(UpperCaseTextFormatter());
    }

    if (keyboardType == TextInputType.phone) {
      inputFormatter.addAll(
          [FilteringTextInputFormatter.digitsOnly, PhoneNumberFormatter()]);
    }
    return inputFormatter;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      style: TextStylesApp.regular(
        color: enabled ? ColorsApp.coalDarkest : ColorsApp.coalBase,
        fontSize: FontSizeApp.s16,
      ),
      inputFormatters: _createInputFormatter(),
      keyboardType: keyboardType,
      onTap: onTap,
      cursorColor: ColorsApp.coalDarkest,
      decoration: InputDecoration(
        fillColor: enabled ? ColorsApp.fogBackground : ColorsApp.coalLighter,
        hintText: hint,
        hintStyle: TextStylesApp.regular(color: ColorsApp.coalBase),
        //0.01 hack: https://stackoverflow.com/questions/56426262/how-to-remove-error-message-in-textformfield-in-flutter
        errorStyle: const TextStyle(height: 0.01, color: Colors.transparent),
        errorText: errorText,
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        prefixIcon: prefixIcon != null
            ? SvgPicture.asset(
                prefixIcon!,
                height: SizeApp.s20,
                width: SizeApp.s20,
              )
            : null,
      ),
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
    );
  }
}
