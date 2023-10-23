import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:octo360/application/enum/battery_connection_status.dart';
import 'package:octo360/application/enum/electrodes_status_enum.dart';
import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo360/domain/model/device/octobeat_device_domain.dart';
import 'package:octo360/presentation/widgets/cell/time_cell/time_cell.dart';
import 'package:octo360/presentation/widgets/chip/warning_chip/warning_chip.dart';
import 'package:octo360/presentation/widgets/separator/dash_separator/dash_separator.dart';
import 'package:octo360/src/colors/colors_app.dart';
import 'package:octo360/src/fonts/font_manager.dart';
import 'package:octo360/src/images/image_manager.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:octo360/src/styles/text_styles_app.dart';
import 'package:octo360/src/values/values_manager.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class OctoBeatDeviceCard extends StatelessWidget {
  final OctobeatDeviceDomain device;
  final bool isBluetoothConntected;
  const OctoBeatDeviceCard({
    Key? key,
    required this.device,
    required this.isBluetoothConntected,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PaddingApp.p20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusApp.r16),
        color: ColorsApp.white,
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderLogo(),
          _renderStudyStatusContainer(),
          _renderBatteryContainer(),
        ],
      ),
    );
  }

  Widget _renderLogo() => SvgPicture.asset(ImagesApp.octobeatTextLogo);

  Widget _renderText(String text) {
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m24),
      child: Text(
        text,
        style: TextStylesApp.medium(
          color: ColorsApp.coalDarker,
          fontSize: FontSizeApp.s18,
        ),
      ),
    );
  }

  Widget _renderStudyStatusContainer() {
    switch (device.studyStatus) {
      case OctoBeatStudyStatus.studyUploading:
        return _renderStudyUploading();
      case OctoBeatStudyStatus.studyUploaded:
        return _renderStudyProgressView(
          title: 'Khảo sát đã kết thúc',
          img: ImagesApp.studyUploaded,
          status: 'Dữ liệu đã được tải lên',
        );
      case OctoBeatStudyStatus.studyDone:
        return _renderStudyProgressView(
          title: 'Khảo sát đã kết thúc',
          img: ImagesApp.studyCompleted,
          status: 'Hoàn tất tải lên dữ liệu',
        );
      default:
        return _renderStudyTimeContainer();
    }
  }

  Widget _renderStudyUploading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderText('Khảo sát đã kết thúc'),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: MarginApp.m28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                ImagesApp.studyUploading,
                frameRate: FrameRate.max,
              ),
              Container(
                margin: const EdgeInsets.only(top: MarginApp.m8),
                child: Text(
                  'Dữ liệu đang được tải lên',
                  style: TextStylesApp.medium(
                    color: ColorsApp.coalDark,
                    fontSize: FontSizeApp.s16,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderStudyTimeContainer() {
    final time = _remaningStudyTime();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderText('Thời gian còn lại của khảo sát'),
        Container(
          margin: const EdgeInsets.only(top: MarginApp.m28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TimeCell(
                value: '${time[0]}',
                unit: StringsApp.day,
                bgImage: ImagesApp.circleDay,
              ),
              TimeCell(
                value: '${time[1]}',
                unit: StringsApp.hour,
                bgImage: ImagesApp.circleHour,
              ),
              TimeCell(
                value: '${time[2]}',
                unit: StringsApp.minute,
                bgImage: ImagesApp.circleMin,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderStudyProgressView({
    required String title,
    required String img,
    required String status,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderText(title),
        Container(
          margin: const EdgeInsets.only(top: MarginApp.m28),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SvgPicture.asset(img),
                Container(
                  margin: const EdgeInsets.only(top: MarginApp.m8),
                  child: Text(
                    status,
                    style: TextStylesApp.medium(
                      color: ColorsApp.coalDark,
                      fontSize: FontSizeApp.s16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///return remaining of study time => [day, hour, minute]
  List<int> _remaningStudyTime() {
    final start = device.startStudyTime;
    final stop = device.stopStudyTime;
    if (start == null || stop == null) {
      return [0, 0, 0];
    }

    final duration = stop.difference(start).inMinutes;
    final spentDuration = DateTime.now().difference(start).inMinutes;
    final remaingingDuration = duration - spentDuration;
    final day = remaingingDuration ~/ (24 * 60);
    final hour = remaingingDuration ~/ 60;
    final minute = remaingingDuration % 60;
    return [day, hour, minute];
  }

  Widget _renderBatteryContainer() {
    if (!device.isConnected ||
        device.studyStatus == OctoBeatStudyStatus.studyDone) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m24),
      child: Column(
        children: [
          DashSeparator(
            color: ColorsApp.coalLightest,
            dashWidth: SizeApp.s4,
          ),
          Container(
            margin: const EdgeInsets.only(top: MarginApp.m24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_renderBatteryInfo(), _renderBatteryStatus()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBatteryInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(device.batteryStatus.iconBaterry),
            Container(
              margin: const EdgeInsets.only(left: MarginApp.m8),
              child: Text(
                device.batteryStatus.getBaterryStr,
                style: TextStylesApp.regular(
                  color: device.batteryStatus.textColor,
                  fontSize: FontSizeApp.s15,
                ),
              ),
            ),
          ],
        ),
        Text(
          '${device.batteryLevel}${StringsApp.percent}',
          style: TextStylesApp.semiBold(
            color: device.batteryStatus.textColor,
            fontSize: FontSizeApp.s22,
          ),
        )
      ],
    );
  }

  Widget _renderBatteryStatus() {
    if (device.batteryStatus == BatteryConnectionStatus.charging) {
      return Container(
        margin: const EdgeInsets.only(top: MarginApp.m6),
        child: Text(
          StringsApp.charging,
          style: TextStylesApp.regular(
            color: ColorsApp.secondaryBase,
            fontSize: FontSizeApp.s15,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: MarginApp.m6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thời gian tương ứng',
            style: TextStylesApp.regular(
              color: ColorsApp.coalDarker,
              fontSize: FontSizeApp.s15,
            ),
          ),
          Text(
            device.formatRemainingTime(),
            style: TextStylesApp.medium(
              color: ColorsApp.coalDarker,
              fontSize: FontSizeApp.s16,
            ),
          )
        ],
      ),
    );
  }
}
