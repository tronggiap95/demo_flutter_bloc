import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:octo360/application/enum/device_type_enum.dart';
import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:octo360/presentation/navigation/routes/routes.dart';
import 'package:octo360/presentation/widgets/bottom_sheet/contact_support_bottom_sheet/contact_support_bottom_sheet.dart';
import 'package:octo360/presentation/widgets/card/multiple_select_card/multiple_select_card.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/values/values_manager.dart';

// ignore: must_be_immutable
class DevicesSupportCard extends StatelessWidget {
  DeviceTypeEnum deviceType;
  DevicesSupportCard({Key? key, required this.deviceType}) : super(key: key);

  final supportList = [
    SelectCardItem(ImagesApp.icUserManualDevices, StringsApp.userManual),
    SelectCardItem(
        ImagesApp.icTroubleshootingDevices, StringsApp.troubleshooting),
    SelectCardItem(
        ImagesApp.icContactSupportDevices, StringsApp.contactSupport),
  ];

  @override
  Widget build(BuildContext context) {
    return MultipleSelectCard(
      data: supportList,
      onTap: (index) => _onTapItem(context, index),
    );
  }

  DeviceSupportEnum convertToDeviceSupportEnum(int index) {
    switch (index) {
      case 0:
        return DeviceSupportEnum.userManual;
      case 1:
        return DeviceSupportEnum.troubleshooting;
      case 2:
        return DeviceSupportEnum.contactSupport;
      default:
        return DeviceSupportEnum.userManual;
    }
  }

  void _onTapItem(BuildContext context, int index) {
    final supportType = convertToDeviceSupportEnum(index);

    switch (supportType) {
      case DeviceSupportEnum.userManual:
        NavigationApp.routeTo(context, Routes.octoBeatAllQuickGuideScreen);
        break;
      case DeviceSupportEnum.troubleshooting:
        NavigationApp.routeTo(context, Routes.octoBeatTroubleshootingRoute);
        break;
      case DeviceSupportEnum.contactSupport:
        showCupertinoModalBottomSheet(
          duration: DurationsApp.bottomSheetFullScreenDuration,
          animationCurve: Curves.easeOut,
          enableDrag: false,
          context: context,
          builder: (context) => const ContactSupportBottomSheet(),
          barrierColor: Colors.transparent.withOpacity(0.5),
          topRadius: const Radius.circular(RadiusApp.r16),
        );
        break;
    }
  }
}
