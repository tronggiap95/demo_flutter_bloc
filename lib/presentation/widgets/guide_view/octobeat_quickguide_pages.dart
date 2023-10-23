import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:octo360/presentation/widgets/button/fill_button/fill_button.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctobeatQuickGuideItem {
  final String header;
  final String imagePath;
  final String firstContent;
  final String secondContent;
  final String thirdContent;
  final String firstIconPath;
  final String secondIconPath;
  final String thirdIconPath;
  final bool hasBack;
  final bool hasNext;
  final bool isWarning;
  OctobeatQuickGuideItem(
    this.header,
    this.imagePath,
    this.firstContent,
    this.secondContent,
    this.thirdContent,
    this.hasBack,
    this.hasNext,
    this.firstIconPath,
    this.secondIconPath,
    this.thirdIconPath,
    this.isWarning,
  );
}

class OctobeatQuickGuidePages extends StatelessWidget {
  const OctobeatQuickGuidePages(
      {super.key,
      required this.octobeatItem,
      this.onPressedBack,
      this.onPressedNext});
  final OctobeatQuickGuideItem octobeatItem;

  final VoidCallback? onPressedBack;
  final VoidCallback? onPressedNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: kIsWeb
          ? const EdgeInsets.symmetric(vertical: MarginApp.m4)
          : Platform.isIOS
              ? const EdgeInsets.symmetric(vertical: 0)
              : const EdgeInsets.symmetric(vertical: MarginApp.m4),
      padding: const EdgeInsets.symmetric(horizontal: PaddingApp.p16),
      child: Column(
        children: [
          _renderHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: <Widget>[
                          _renderImage(),
                          Expanded(child: _renderContent()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _renderNavButton()
        ],
      ),
    );
  }

  Widget _renderHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            octobeatItem.header,
            textAlign: TextAlign.center,
            style: TextStylesApp.bold(
              color: ColorsApp.coalDarkest,
              fontSize: FontSizeApp.s22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderNavButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              octobeatItem.hasBack
                  ? SizedBox(
                      width: 101,
                      height: 41,
                      child: TextButton(
                        onPressed: () {
                          onPressedBack?.call();
                        },
                        child: Text(
                          StringsApp.back,
                          style: TextStylesApp.bold(
                            color: ColorsApp.primaryBase,
                            fontSize: FontSizeApp.s16,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              octobeatItem.hasNext
                  ? FilledButtonApp(
                      label: octobeatItem.isWarning == false
                          ? StringsApp.next
                          : StringsApp.gotIt,
                      onPressed: () {
                        onPressedNext?.call();
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(height: MarginApp.m24),
      ],
    );
  }

  Widget _renderContent() {
    return octobeatItem.isWarning
        ? _renderWarningContent()
        : _renderNormalContent();
  }

  Widget _renderNormalContent() {
    return Column(
      children: [
        _renderFirstNormalContent(),
        const SizedBox(height: MarginApp.m16),
        _renderSecondNormalContent(),
        const SizedBox(height: MarginApp.m16),
        _renderThirdNormalContent(),
      ],
    );
  }

  Widget _renderThirdNormalContent() {
    return Row(
      children: [
        octobeatItem.thirdIconPath.contains('.png')
            ? Image(image: AssetImage(octobeatItem.thirdIconPath))
            : octobeatItem.imagePath.contains('.json')
                ? Lottie.asset(
                    ImagesApp.loadingAnimation,
                    frameRate: FrameRate.max,
                  )
                : SvgPicture.asset(octobeatItem.thirdIconPath),
        const SizedBox(width: MarginApp.m16),
        Expanded(
          child: Text(
            octobeatItem.thirdContent,
            textAlign: TextAlign.left,
            style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s14),
          ),
        ),
      ],
    );
  }

  Widget _renderSecondNormalContent() {
    return Row(
      children: [
        octobeatItem.secondIconPath.contains('.png')
            ? Image(image: AssetImage(octobeatItem.secondIconPath))
            : octobeatItem.imagePath.contains('.json')
                ? Lottie.asset(
                    ImagesApp.loadingAnimation,
                    frameRate: FrameRate.max,
                  )
                : SvgPicture.asset(octobeatItem.secondIconPath),
        const SizedBox(width: MarginApp.m16),
        Expanded(
          child: Text(
            octobeatItem.secondContent,
            textAlign: TextAlign.left,
            style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s14),
          ),
        ),
      ],
    );
  }

  Widget _renderFirstNormalContent() {
    return Row(
      children: [
        octobeatItem.firstIconPath.contains('.png')
            ? Image(image: AssetImage(octobeatItem.firstIconPath))
            : octobeatItem.imagePath.contains('.json')
                ? Lottie.asset(
                    ImagesApp.loadingAnimation,
                    frameRate: FrameRate.max,
                  )
                : SvgPicture.asset(octobeatItem.firstIconPath),
        const SizedBox(width: MarginApp.m16),
        Expanded(
          child: Text(
            octobeatItem.firstContent,
            textAlign: TextAlign.left,
            style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s14),
          ),
        ),
      ],
    );
  }

  Widget _renderWarningContent() {
    return Column(
      children: [
        Text(
          octobeatItem.firstContent,
          style: TextStylesApp.bold(
            color: ColorsApp.redBase,
            fontSize: FontSizeApp.s30,
          ),
        ),
        const SizedBox(height: MarginApp.m16),
        Text(
          octobeatItem.secondContent,
          style: TextStylesApp.bold(
            color: ColorsApp.coalDarkest,
            fontSize: FontSizeApp.s22,
          ),
        ),
      ],
    );
  }

  Widget _renderImage() {
    return Column(
      children: [
        const SizedBox(height: MarginApp.m24),
        octobeatItem.imagePath.contains('.png') ||
                octobeatItem.imagePath.contains('.jpg')
            ? Image(
                image: AssetImage(octobeatItem.imagePath),
                width: 240,
              )
            : octobeatItem.imagePath.contains('.json')
                ? Lottie.asset(
                    ImagesApp.loadingAnimation,
                    frameRate: FrameRate.max,
                  )
                : SvgPicture.asset(octobeatItem.imagePath),
        const SizedBox(height: MarginApp.m8),
      ],
    );
  }
}
