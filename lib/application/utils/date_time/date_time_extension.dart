import 'package:intl/intl.dart';
import 'package:octo360/application/enum/time_duration_enum.dart';
import 'package:octo360/src/strings/string_manager.dart';

/// Name Rule: to + "Date Time Format" + "Format"
/// Special characters:
/// "/": sl
/// "-": ml
/// "_": ll
/// ",": cm
extension DateTimeExtension on DateTime {
  int get daysOfMonth => DateTime(year, month + 1, 0).day;

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  DateTime roundMinutes(int min) {
    final offset = DateTime.now().timeZoneOffset.inMilliseconds;
    final currentTimeInEpoch = millisecondsSinceEpoch + offset;
    final minInMiliSeconds = min * 60 * 1000;
    final roundMinuteEpoch =
        (currentTimeInEpoch ~/ minInMiliSeconds) * minInMiliSeconds;
    return DateTime.fromMillisecondsSinceEpoch(roundMinuteEpoch - offset);
  }

  bool isSameMomentIn({
    TimeDurationEnum sameIn = TimeDurationEnum.second,
    required DateTime otherTime,
  }) {
    bool _isTheSameInYear() {
      return year == otherTime.year;
    }

    bool _isTheSameInMonth() {
      return year == otherTime.year && month == otherTime.month;
    }

    bool _isTheSameInDay() {
      return year == otherTime.year &&
          month == otherTime.month &&
          day == otherTime.day;
    }

    bool _isTheSameInHour() {
      return year == otherTime.year &&
          month == otherTime.month &&
          day == otherTime.day &&
          hour == otherTime.hour;
    }

    bool _isTheSameInMinute() {
      return year == otherTime.year &&
          month == otherTime.month &&
          day == otherTime.day &&
          hour == otherTime.hour &&
          minute == otherTime.minute;
    }

    bool _isTheSameInSecond() {
      return year == otherTime.year &&
          month == otherTime.month &&
          day == otherTime.day &&
          hour == otherTime.hour &&
          minute == otherTime.minute &&
          second == otherTime.second;
    }

    switch (sameIn) {
      case TimeDurationEnum.year:
        return _isTheSameInYear();
      case TimeDurationEnum.month:
        return _isTheSameInMonth();
      case TimeDurationEnum.day:
        return _isTheSameInDay();
      case TimeDurationEnum.hour:
        return _isTheSameInHour();
      case TimeDurationEnum.minute:
        return _isTheSameInMinute();
      case TimeDurationEnum.second:
        return _isTheSameInSecond();
      default:
        return _isTheSameInSecond();
    }
  }

  bool isSameOrAfter(DateTime? date) {
    if (date == null) {
      return false;
    }
    return isAfter(date) || isAtSameMomentAs(date);
  }

  bool isSameOrBefore(DateTime date) {
    return isBefore(date) || isAtSameMomentAs(date);
  }

  /// fromTime <= time <= toTime
  bool isBetween({required DateTime fromTime, required DateTime toTime}) {
    if (isSameOrAfter(fromTime) && isSameOrBefore(toTime)) {
      return true;
    }
    return false;
  }

  /// Difference between months (30 days)
  ///
  /// ex: 2022-08-13 diff From 2022-08-14 ->  0
  ///
  /// ex: 2022-09-20 diff From 2022-08-13 ->  1
  ///
  /// ex: 2022-08-13 diff From 2022-09-20 -> -1
  int diffInMonth(DateTime date) {
    return difference(date).inDays ~/ 30;
  }

  // Check if current time is before an input time
  bool isBeforeIn({
    required TimeDurationEnum beforeIn,
    required DateTime comparedDate,
  }) {
    bool _isBeforeSecond() {
      return isBefore(comparedDate);
    }

    bool _isBeforeDay() {
      final startOfDay = DateTime(
        comparedDate.year,
        comparedDate.month,
        comparedDate.day,
      );

      return isBefore(startOfDay);
    }

    switch (beforeIn) {
      case TimeDurationEnum.day:
        return _isBeforeDay();
      default:
        return _isBeforeSecond();
    }
  }

  DateTime toStartOfDay() {
    return DateTime(year, month, day, 0, 0, 0);
  }

  // to millisecond to convert to epoch
  DateTime toStopOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}
