import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/application/enum/device_status_enum.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class DevicesWarningSection extends StatelessWidget {
  final DevicesStatusEnum devicesStatus;
  final String hightLightWarning;
  final VoidCallback onPressedButton;
  final VoidCallback? onPressedWarning;
  const DevicesWarningSection(
      {Key? key,
      required this.devicesStatus,
      required this.onPressedButton,
      this.onPressedWarning,
      required this.hightLightWarning})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: PaddingApp.p12,
          left: PaddingApp.p12,
          right: PaddingApp.p12,
          bottom: PaddingApp.p16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsApp.redLightest,
        borderRadius: const BorderRadius.all(
          Radius.circular(RadiusApp.r8),
        ),
      ),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _renderIcon(),
            const SizedBox(width: MarginApp.m8),
            _renderDetail(context),
          ],
        ),
        const SizedBox(height: MarginApp.m12),
        _renderButton(),
      ]),
    );
  }

  Widget _renderIcon() {
    return GestureDetector(
      onTap: onPressedWarning,
      child: AbsorbPointer(
        child: SvgPicture.asset(ImagesApp.icWarningRed),
      ),
    );
  }

  Widget _renderDetail(BuildContext context) {
    return Flexible(
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: _detailMessage(devicesStatus),
              style: TextStylesApp.regular(
                color: ColorsApp.coalDarkest,
                fontSize: FontSizeApp.s14,
              ),
            ),
            TextSpan(
                text: hightLightWarning,
                style: TextStylesApp.medium(
                  color: ColorsApp.redBase,
                  fontSize: FontSizeApp.s14,
                )),
          ],
        ),
      ),
    );
  }

  Widget _renderButton() {
    return GestureDetector(
      onTap: onPressedButton,
      child: AbsorbPointer(
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PaddingApp.p16,
              vertical: PaddingApp.p6,
            ),
            decoration: BoxDecoration(
              color: ColorsApp.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(RadiusApp.r8),
              ),
            ),
            child: Text(
              _detailButton(devicesStatus),
              style: TextStylesApp.bold(
                color: ColorsApp.coalDarkest,
                fontSize: SizeApp.s14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _detailMessage(DevicesStatusEnum devicesStatus) {
    switch (devicesStatus) {
      case DevicesStatusEnum.issueWarning:
        return StringsApp.detailIssueWarning;
      default:
        return '';
    }
  }

  String _detailButton(DevicesStatusEnum devicesStatus) {
    switch (devicesStatus) {
      case DevicesStatusEnum.issueWarning:
        return StringsApp.viewSolution;
      default:
        return '';
    }
  }
}
