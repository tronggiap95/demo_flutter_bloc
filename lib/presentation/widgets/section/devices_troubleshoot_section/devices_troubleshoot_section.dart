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

class DevicesTroubleshootSection extends StatelessWidget {
  final DevicesStatusEnum devicesStatus;
  final VoidCallback onPressedButton;
  final DeviceTypeEnum deviceType;
  const DevicesTroubleshootSection({
    Key? key,
    required this.devicesStatus,
    required this.onPressedButton,
    this.deviceType = DeviceTypeEnum.octoBeat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsApp.orangeBase,
        borderRadius: const BorderRadius.all(Radius.circular(RadiusApp.r8)),
      ),
      padding: const EdgeInsets.all(PaddingApp.p6),
      child: Container(
        padding: const EdgeInsets.only(
          top: PaddingApp.p12,
          left: PaddingApp.p12,
          right: PaddingApp.p12,
          bottom: PaddingApp.p16,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorsApp.orangeLightest,
          borderRadius: const BorderRadius.all(Radius.circular(RadiusApp.r8)),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(
            children: [
              _renderIcon(),
              const SizedBox(width: MarginApp.m8),
              Text(
                StringsApp.attentionNeeded,
                style: TextStylesApp.medium(
                    color: ColorsApp.coalDarkest, fontSize: FontSizeApp.s18),
              )
            ],
          ),
          const SizedBox(height: MarginApp.m8),
          _renderDetail(),
          const SizedBox(height: MarginApp.m12),
          _renderButton(),
        ]),
      ),
    );
  }

  Widget _renderIcon() {
    return SvgPicture.asset(ImagesApp.icAttentionNeeded);
  }

  Widget _renderDetail() {
    return Text(
      _detailMessage(),
      style: TextStylesApp.regular(
        color: ColorsApp.coalDarkest,
        fontSize: FontSizeApp.s14,
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
              border: Border.all(
                color: ColorsApp.coalDarker,
                width: 1,
              ),
            ),
            child: Text(
              _detailButton(devicesStatus),
              style: TextStylesApp.bold(
                color: ColorsApp.coalDarker,
                fontSize: FontSizeApp.s15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _detailMessage() {
    switch (devicesStatus) {
      case DevicesStatusEnum.disconnectTroubleshoot:
        return StringsApp.oneOrMoreElectrodesHave;

      case DevicesStatusEnum.offlineTroubleshoot:
        return StringsApp.yourDeviceHasBeenOfflineFor;

      case DevicesStatusEnum.lowbatterryTroubleshoot:
        return StringsApp.yourDeviceBatterySeemsLow;

      case DevicesStatusEnum.bluetoothTurnOff:
        return StringsApp.bluetoothIsDisabledPleaseEnableIt;

      default:
        return '';
    }
  }

  String _detailButton(DevicesStatusEnum devicesStatus) {
    switch (devicesStatus) {
      case DevicesStatusEnum.disconnectTroubleshoot:
        return StringsApp.proceedWithAssistance;

      case DevicesStatusEnum.offlineTroubleshoot:
        return StringsApp.connectionTroubleshoot;

      case DevicesStatusEnum.lowbatterryTroubleshoot:
        return StringsApp.learnMore;

      case DevicesStatusEnum.bluetoothTurnOff:
        return StringsApp.goToSettings;
      default:
        return '';
    }
  }
}
