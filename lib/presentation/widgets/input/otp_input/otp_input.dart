import 'dart:io';

import 'package:flutter/material.dart';
import 'package:octo360/application/utils/string/string_utils.dart';
import 'package:octo360/presentation/widgets/label/label_error.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';
import 'package:sms_autofill/sms_autofill.dart';
// import 'package:sms_autofill/sms_autofill.dart';

class OtpInput extends StatefulWidget {
  final String? error;
  final TextInputType textInputType;
  final Function(String) onChanged;
  final Function()? onFocus;
  final Function(bool)? setShowKeyboard;
  final Function()? onDone;
  final TextCapitalization textCapitalization;
  final bool shouldShowKeyboard;
  final bool isAutoFillSms;
  final int? keyboardShowDuration;

  const OtpInput({
    Key? key,
    required this.error,
    required this.onChanged,
    this.onFocus,
    this.setShowKeyboard,
    this.onDone,
    this.textInputType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.shouldShowKeyboard = false,
    this.isAutoFillSms = false,
    this.keyboardShowDuration,
  }) : super(key: key);

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> with CodeAutoFill {
  String _code = '';
  String? _otpCode;
  String _prevChar = '';
  String? _error = '';
  final List<FocusNode> _listFocus = List<FocusNode>.filled(6, FocusNode());
  final List<TextEditingController> _listController =
      List<TextEditingController>.filled(6, TextEditingController());

  List<bool> listFocusState = [false, false, false, false, false, false];
  @override
  void initState() {
    _assignController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  void codeUpdated() {
    if (_isValidateOtp()) {
      setState(() {});
      _getCodeFromSms();
    }
  }

  // function check code is valid
  bool _isValidateOtp() {
    if (StringUtils.isNotNullOrEmpty(code)) {
      //* Code includes only numbers
      if (code!.length == 6) {
        _otpCode = code;
        return true;
      }
      //* Code includes numbers and characters
      if (code!.length > 6) {
        _otpCode =
            code?.substring(code!.indexOf(':') + 2, code!.indexOf(':') + 8);
        _otpCode?.replaceAll(' ', '');
        if (_otpCode?.length == 6) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setShowKeyboardIos();
    _setListenSms();
  }

  void _setListenSms() {
    if (widget.isAutoFillSms) listenForCode();
  }

  //Focus/unFocus event
  void _handleFocusAtIndex(int index) {
    if (_listFocus[index].hasFocus) {
      if (_listController[index].text.isEmpty && index != 0) {
        _listController[index].text = " ";
      }
      _prevChar = _listController[index].text;

      widget.onFocus?.call();
      _updateText();

      _updateCellColor(index);
    } else {
      _updateCellColor();
    }
  }

  void _updateCellColor([int? index]) {
    List<bool> temp = [false, false, false, false, false, false];
    if (index != null) {
      temp[index] = true;
    }
    setState(() {
      listFocusState = temp;
    });
  }

  void _assignController() {
    for (int i = 0; i < 6; i++) {
      _listController[i] = TextEditingController();
      _listFocus[i] = FocusNode();
      _listFocus[i].addListener(() {
        _handleFocusAtIndex(i);
      });
    }
  }

  void _handleOnChangeValue(String value, int index) {
    //auto capital input string
    _listController[index].text = _listController[index].text.toUpperCase();

    // handle copy event
    if (value.length > 2) {
      //remove redundance char
      String copyValue = value.replaceAll(RegExp(r' '), '').toUpperCase();

      _handleCopy(copyValue);
    }

    // first field always has empty text, so check length == 1 move to next field
    if (index == 0 && value.length == 1) {
      _listController[index].text = _listController[index].text[0];
      _updateText();
      _updateCellColor();
      //move to next field
      FocusScope.of(context).nextFocus();
    }

    // When user paste a text with 6 characters, done function will be called.
    if (value.length == 6) {
      widget.onDone?.call();
    }

    // The user enters over the field that already has the word
    if (value.length == 2) {
      _listController[index].text = _listController[index].text[1];
      _updateText();

      //move to next field
      if (index == 5) {
        FocusScope.of(context).unfocus();
        _updateCellColor();
      } else {
        FocusScope.of(context).nextFocus();
      }
    }

    if (value.isEmpty) {
      _listController[index].text = " ";
      _updateText();

      //press back button
      if (index == 0) {
        FocusScope.of(context).unfocus();
      } else {
        if (_prevChar != " ") {
          _prevChar = " ";
        } else {
          FocusScope.of(context).previousFocus();
        }
      }
    }

    _listController[index].selection = TextSelection(
        baseOffset: _listController[index].text.length,
        extentOffset: _listController[index].text.length);
  }

  void _handleCopy(String value) {
    _resetText();
    for (int i = 0; i < value.length; i++) {
      if (i == 6) return;
      _listController[i].text = value[i];
    }
    _updateText();
    FocusScope.of(context).unfocus();
  }

  void _resetText() {
    _listController[0].text = "";
    _listController[1].text = "";
    _listController[2].text = "";
    _listController[3].text = "";
    _listController[4].text = "";
    _listController[5].text = "";
  }

  void _updateText() {
    String text0 = _listController[0].text;
    String text1 = _listController[1].text;
    String text2 = _listController[2].text;
    String text3 = _listController[3].text;
    String text4 = _listController[4].text;
    String text5 = _listController[5].text;
    _code = "$text0$text1$text2$text3$text4$text5";
    widget.onChanged(_code.replaceAll(RegExp(r' '), ''));
  }

  Color _renderColorStatus(int index) {
    if (_error == null) {
      if (_listFocus[index].hasFocus) {
        return ColorsApp.coalDarkest;
      }
      return ColorsApp.fogBackground;
    } else {
      return ColorsApp.redBase;
    }
  }

  Widget _ceilOtp(BuildContext context, autoFocus, index) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BorderRadiusApp.r10)),
      height: 44,
      width: 48,
      child: TextFormField(
        autofocus: autoFocus,
        obscureText: false,
        style: TextStylesApp.medium(
            color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s16),
        textAlign: TextAlign.center,
        keyboardType: widget.textInputType,
        focusNode: _listFocus[index],
        controller: _listController[index],
        textCapitalization: widget.textCapitalization,
        // inputFormatters: [LengthLimitingTextInputFormatter(2)],
        //hide cursor bubble
        // enableInteractiveSelection: false,
        //hide cursor
        cursorColor: Colors.transparent,
        cursorWidth: 0,
        cursorHeight: 0,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: InputBorder.none,
          filled: true,
          fillColor: ColorsApp.fogBackground,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        onTap: () {
          // _currentIndex = index;
          //Cursor auto in the end of text.
          _listController[index].selection = TextSelection(
              baseOffset: _listController[index].text.length,
              extentOffset: _listController[index].text.length);
        },
        onChanged: (value) {
          _handleOnChangeValue(value, index);
        },
      ),
    );
  }

  Widget _renderOtpInputField(BuildContext context, autoFocus, index) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorsApp.fogBackground,
        border: Border.all(
          color: _renderColorStatus(index),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: _ceilOtp(context, autoFocus, index),
    );
  }

  void _getCodeFromSms() {
    if (_otpCode != null) {
      for (int i = 0; i < 6; i++) {
        _listController[i] =
            TextEditingController(text: _otpCode!.substring(i, i + 1));
      }
      _updateText();
      widget.onDone?.call();
      _otpCode = null;
    }
  }

  void _setShowKeyboardIos() {
    if (widget.shouldShowKeyboard && Platform.isIOS) {
      Future.delayed(
          Duration(milliseconds: widget.keyboardShowDuration ?? 1500), () {
        _listController[0].text = "";
        _updateCellColor(0);
        FocusScope.of(context).requestFocus(_listFocus[0]);
        if (widget.setShowKeyboard != null) {
          widget.setShowKeyboard!(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _error = widget.error;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _renderOtpInputField(context, false, 0),
            _renderOtpInputField(context, false, 1),
            _renderOtpInputField(context, false, 2),
            _renderOtpInputField(context, false, 3),
            _renderOtpInputField(context, false, 4),
            _renderOtpInputField(context, false, 5),
          ],
        ),
        const SizedBox(height: MarginApp.m4),
        widget.error?.isNotEmpty == true
            ? LblError(errText: widget.error!)
            : Container(),
      ],
    );
  }
}
