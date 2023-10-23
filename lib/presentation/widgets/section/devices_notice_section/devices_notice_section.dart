import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo360/application/enum/device_status_enum.dart';
import 'package:octo360/application/enum/device_type_enum.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';

class DevicesNoticeSection extends StatelessWidget {
  final DevicesStatusEnum devicesStatus;
  final VoidCallback? onPressedButton;
  final DeviceTypeEnum deviceType;
  const DevicesNoticeSection({
    Key? key,
    required this.devicesStatus,
    this.onPressedButton,
    this.deviceType = DeviceTypeEnum.octoBeat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PaddingApp.p12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsApp.coalLightest,
        borderRadius: const BorderRadius.all(
          Radius.circular(RadiusApp.r8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(17, 24, 39, 0.08),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _renderIcon(),
            const SizedBox(width: MarginApp.m8),
            _renderDetail(),
            const SizedBox(height: MarginApp.m8),
            _renderButton()
          ]),
    );
  }

  Widget _renderIcon() {
    return SvgPicture.asset(ImagesApp.icInformationBlue);
  }

  Widget _renderDetail() {
    return Flexible(
      child: Text(
        _detailMessage(),
        style: TextStylesApp.regular(
          color: ColorsApp.coalDarkest,
          fontSize: FontSizeApp.s14,
        ),
      ),
    );
  }

  Widget _renderButton() {
    return GestureDetector(
      onTap: onPressedButton,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PaddingApp.p6,
            vertical: PaddingApp.p2,
          ),
          child: Text(
            StringsApp.okay,
            style: TextStylesApp.bold(
              color: ColorsApp.primaryBase,
              fontSize: SizeApp.s16,
            ),
          ),
        ),
      ),
    );
  }

  String _detailMessage() {
    switch (devicesStatus) {
      case DevicesStatusEnum.disconnectNotice:
        return StringsApp.deviceDisconnectedPleaseMakeSure;
      case DevicesStatusEnum.offlineNotice:
        return StringsApp.yourDeviceHasBeenOffline;
      case DevicesStatusEnum.cableLooseNotice:
        return StringsApp.oneOrMoreElectrodesSeem;
      default:
        return '';
    }
  }
}
