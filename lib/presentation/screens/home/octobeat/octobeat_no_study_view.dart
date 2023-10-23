import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class OctobeatNoStudyView extends StatelessWidget {
  const OctobeatNoStudyView({required this.phoneNumber, super.key});
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PaddingApp.p16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _renderImage(),
                _renderTitle(),
                _renderMsg(),
              ],
            ),
            _renderSolutions()
          ],
        ),
      ),
    );
  }

  Container _renderSolutions() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m32),
      padding: const EdgeInsets.all(PaddingApp.p12),
      decoration: BoxDecoration(
        color: ColorsApp.blueLightest,
        borderRadius: const BorderRadius.all(
          Radius.circular(RadiusApp.r8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: MarginApp.m12),
            child: SvgPicture.asset(ImagesApp.icLightbulb),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringsApp.pleaseMakeSureTheSignIn,
                  style: TextStylesApp.regular(
                    color: ColorsApp.coalDarkest,
                    fontSize: FontSizeApp.s14,
                    lineHeight: SizeApp.s24,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: MarginApp.m4),
                  child: Text(
                    phoneNumber,
                    style: TextStylesApp.medium(
                      color: ColorsApp.coalDarkest,
                      fontSize: FontSizeApp.s14,
                      lineHeight: SizeApp.s24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderMsg() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m12),
      child: Text(
        StringsApp.itSeemsLikeThereIsNo,
        style: TextStylesApp.regular(
          color: ColorsApp.coalDarker,
          fontSize: FontSizeApp.s14,
          lineHeight: SizeApp.s24,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _renderTitle() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m32),
      child: Text(
        StringsApp.weCantFindAnythingHere,
        style: TextStylesApp.medium(
          color: ColorsApp.coalDarker,
          fontSize: FontSizeApp.s22,
        ),
      ),
    );
  }

  Widget _renderImage() {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m56),
      child: SvgPicture.asset(ImagesApp.pageNotFound),
    );
  }
}
