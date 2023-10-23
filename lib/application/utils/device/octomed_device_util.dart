import 'package:octo360/application/utils/date_time/date_time_utils.dart';
import 'package:octo_beat_plugin/model/octo_beat_study_status_enum.dart';

class DeviceUtil {
  static double? calculateStudyProgress(
    DateTime? start,
    DateTime? stop,
    OctoBeatStudyStatus currentStudyStatus,
  ) {
    if (start == null || stop == null) {
      return null;
    }
    if (currentStudyStatus == OctoBeatStudyStatus.setting) {
      return 0;
    }
    if (currentStudyStatus == OctoBeatStudyStatus.studyCompleted ||
        currentStudyStatus == OctoBeatStudyStatus.studyUploaded ||
        currentStudyStatus == OctoBeatStudyStatus.studyUploading) {
      return 1;
    }

    final duration = stop.difference(start).inMinutes.toDouble();
    final spentDuration = DateTime.now().difference(start).inMinutes.toDouble();
    final percent = duration == 0 ? 0.0 : (spentDuration / duration);
    final result = percent > 1 ? 1.0 : percent;

    return result < 0 ? 0 : result;
  }

  static String calculateRemainingTime(DateTime? start, DateTime? stop) {
    if (start == null || stop == null) {
      return '';
    }

    final duration = stop.difference(start).inMinutes;
    final spentDuration = DateTime.now().difference(start).inMinutes;
    final remaingingDuration = duration - spentDuration;
    return DateTimeUtils.formatStudyRemainingTime(remaingingDuration);
  }
}
