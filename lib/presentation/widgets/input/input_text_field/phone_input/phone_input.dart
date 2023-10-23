import 'package:flutter/material.dart';
import 'package:octo360/domain/model/account/country_code_domain.dart';
import 'package:octo360/presentation/widgets/label/label_error.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class PhoneInput extends StatefulWidget {
  final CountryCodeDomain? countryCodeDomain;
  final ValueChanged<String> onChangedInput;
  final VoidCallback? onPressCountryFlag;
  final String? label;
  final String? initialValue;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputAction? keyboardAction;
  final ValueChanged<String>? onSubmit;
  final bool isRequired;
  final int? maxlength;
  final bool? isShowLabel;

  const PhoneInput({
    Key? key,
    this.countryCodeDomain,
    required this.onChangedInput,
    this.onPressCountryFlag,
    this.label,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.controller,
    this.keyboardAction,
    this.onSubmit,
    this.isRequired = false,
    this.maxlength,
    this.isShowLabel = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<PhoneInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderLabel(),
        _renderMainView(),
        _renderErrorText(),
      ],
    );
  }

  Widget _renderLabel() {
    return widget.isShowLabel ?? true
        ? Column(
            children: [
              RichText(
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: widget.label ?? '',
                  style: TextStylesApp.regular(
                      color: ColorsApp.coalDarker, fontSize: FontSizeApp.s14),
                  children: [
                    if (widget.isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: ColorsApp.coalDarker,
                          fontSize: FontSizeApp.s14,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SizeApp.s8),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _renderMainView() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.fogBackground,
        border: Border.all(
          color: _focusNode.hasFocus
              ? ColorsApp.coalDarkest
              : widget.errorText == null
                  ? Colors.transparent
                  : ColorsApp.redBase,
          width: BorderWidthApp.w1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(RadiusApp.r10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p12),
      child: Row(
        children: [
          _renderCountryCodeButton(),
          _renderSeparateLine(),
          _renderPhoneInput(),
        ],
      ),
    );
  }

  Widget _renderCountryCodeButton() {
    return GestureDetector(
      onTap: widget.onPressCountryFlag,
      child: Container(
        height: SizeApp.s44,
        color: Colors.transparent,
        child: Row(
          children: [
            Text(widget.countryCodeDomain?.flag ?? '🇻🇳'),
            const SizedBox(width: MarginApp.m4),
            Text(
              '+${widget.countryCodeDomain?.dial ?? '84'}',
              style: TextStylesApp.medium(
                  color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s14),
            ),
            const SizedBox(width: MarginApp.m8),
          ],
        ),
      ),
    );
  }

  Widget _renderSeparateLine() {
    return Container(height: 24, width: 1.5, color: ColorsApp.coalLight);
  }

  Widget _renderPhoneInput() {
    return Flexible(
      child: TextFormField(
        focusNode: _focusNode,
        initialValue: widget.initialValue,
        textDirection: TextDirection.ltr,
        controller: widget.controller,
        keyboardType: TextInputType.phone,
        textInputAction: widget.keyboardAction,
        style: TextStylesApp.regular(color: ColorsApp.coalDarkest),
        onFieldSubmitted: widget.onSubmit,
        cursorColor: ColorsApp.coalDarkest,
        decoration: InputDecoration(
          hintText: widget.hintText,
          //0.01 hack: https://stackoverflow.com/questions/56426262/how-to-remove-error-message-in-textformfield-in-flutter
          errorStyle: const TextStyle(height: 0.01, color: Colors.transparent),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          counterText: '',
        ),
        onChanged: widget.onChangedInput,
        maxLength: widget.maxlength,
        enabled: true,
      ),
    );
  }

  Widget _renderErrorText() {
    return widget.errorText?.isNotEmpty == true
        ? Container(
            margin: const EdgeInsets.only(top: MarginApp.m4),
            child: LblError(errText: widget.errorText!),
          )
        : const SizedBox(height: SizeApp.s26);
  }
}
