import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/presentation/widgets/button/outline_button/outline_button.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class CustomDialog extends StatefulWidget {
  final bool isErrorDialog;
  final String? imagePath;
  final String title;
  final bool? isMessageCenter;
  final bool? isTitleCenter;
  final String? message;
  final bool? isSVG;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final String? neutralButtonText;
  final VoidCallback? onPressPositiveButton;
  final VoidCallback? onPressNegativeButton;
  final VoidCallback? onPressNeutraltiveButton;
  final double imageHeight;
  final bool? showLoadingAfterPressPositive;
  final Widget? customMessage;
  final bool hasBorderNeutralButton;
  final Color? textColorNeutralButton;

  const CustomDialog({
    Key? key,
    this.isErrorDialog = false,
    this.imagePath,
    required this.title,
    this.isTitleCenter = false,
    this.isMessageCenter = true,
    this.message,
    this.isSVG = true,
    this.positiveButtonText,
    this.negativeButtonText,
    this.neutralButtonText,
    this.onPressPositiveButton,
    this.onPressNegativeButton,
    this.onPressNeutraltiveButton,
    this.imageHeight = SizeApp.s120,
    this.showLoadingAfterPressPositive = false,
    this.customMessage,
    this.hasBorderNeutralButton = false,
    this.textColorNeutralButton,
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeApp.s12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PaddingApp.p16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _renderImage(),
            _renderTitle(),
            _renderContentText(),
            _renderPositiveButton(),
            _renderNeutralButton(),
            _renderNegativeButton(),
          ],
        ),
      ),
    );
  }

  Widget _renderNegativeButton() {
    return widget.negativeButtonText != null
        ? Container(
            margin: const EdgeInsets.only(top: MarginApp.m4),
            width: double.infinity,
            child: OutlinedButtonApp(
              label: widget.negativeButtonText!,
              hasBorder: false,
              colorText: widget.isErrorDialog ? ColorsApp.coalDarkest : null,
              onPressed: widget.onPressNegativeButton,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _renderNeutralButton() {
    return widget.neutralButtonText != null
        ? Container(
            margin: const EdgeInsets.only(top: MarginApp.m16),
            width: double.infinity,
            child: OutlinedButtonApp(
              label: widget.neutralButtonText!,
              hasBorder: widget.hasBorderNeutralButton,
              colorText: widget.textColorNeutralButton ??
                  (widget.isErrorDialog ? ColorsApp.coalDarkest : null),
              borderColor: widget.isErrorDialog ? ColorsApp.redBase : null,
              onPressed: widget.onPressNeutraltiveButton,
              borderWidth: widget.hasBorderNeutralButton ? 2 : null,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _renderPositiveButton() {
    return widget.positiveButtonText != null
        ? Container(
            margin: const EdgeInsets.only(top: MarginApp.m16),
            width: double.infinity,
            child: FilledButtonApp(
              isLoading: _isLoading,
              label: widget.positiveButtonText ?? '',
              color: widget.isErrorDialog ? ColorsApp.redBase : null,
              onPressed: () {
                if (widget.showLoadingAfterPressPositive == true) {
                  setState(() {
                    _isLoading = true;
                  });
                }
                widget.onPressPositiveButton?.call();
              },
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _renderContentText() {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.only(top: MarginApp.m8),
        child: widget.customMessage != null
            ? widget.customMessage!
            : widget.message != null
                ? Text(
                    widget.message!,
                    style: TextStylesApp.regular(
                      color: ColorsApp.coalDarker,
                      fontSize: FontSizeApp.s14,
                    ),
                    textAlign: widget.isMessageCenter == true
                        ? TextAlign.center
                        : TextAlign.left,
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  Container _renderTitle() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m16),
      child: Text(
        widget.title,
        style: TextStylesApp.medium(color: ColorsApp.coalDarkest),
        textAlign:
            widget.isTitleCenter == true ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _renderImage() {
    return widget.imagePath != null
        ? widget.isSVG == true
            ? SvgPicture.asset(widget.imagePath!, height: widget.imageHeight)
            : Container(
                height: widget.imageHeight,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath!),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
        : const SizedBox.shrink();
  }
}
