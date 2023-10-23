import 'dart:math';

import 'package:intl/intl.dart';
import 'package:octo360/application/constants/calendar_constant.dart';
import 'package:octo360/application/utils/date_time/date_time_extension.dart';
import 'package:octo360/src/strings/string_manager.dart';
import 'package:timezone/timezone.dart' as tz;

class DateTimeUtils {
  ///Default: +84
  static String currentCountryCode() {
    return "+84";
  }

  ///Default: +84
  static String currentRegionCode() {
    return 'VN';
  }

  static String displayMinute(int value) {
    if (value == 0) {
      return '00';
    } else if (value < 10) {
      return '0$value';
    } else {
      return value.toString();
    }
  }

  static String calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '--';
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age.toString();
  }

  static String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '${hourValue}h$minuteString';
  }

  static String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).round()}'.padLeft(2, '0');
  }

  static String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2);
  }

  static DateTime nowInMinutes() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool checkIsToday(DateTime timeToCheck) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final dateOfTimeToCheck =
        DateTime(timeToCheck.year, timeToCheck.month, timeToCheck.day);

    if (dateOfTimeToCheck == today) {
      return true;
    } else {
      return false;
    }
  }

  static int getDifferenceWeekNumber(DateTime dateFrom, DateTime dateTo) {
    //* cal week number Jan-01-1970 is Thu, Jan-01-1970 is Sun. Suppose that from Jan, 01 to 04 is week 0. assume that Monday is first day of week
    final dateFromWeekNumber =
        (dateFrom.toUtc().millisecondsSinceEpoch + 3 * oneDayMilliseconds) ~/
            (7 * oneDayMilliseconds);
    final dateToWeekNumber =
        (dateTo.toUtc().millisecondsSinceEpoch + 3 * oneDayMilliseconds) ~/
            (7 * oneDayMilliseconds);
    return dateToWeekNumber - dateFromWeekNumber;
  }

  static int secondBetween(DateTime from, DateTime to) {
    from = DateTime(
        from.year, from.month, from.day, from.hour, from.minute, from.second);
    to = DateTime(to.year, to.month, to.day, to.hour, to.minute, to.second);
    return (to.difference(from).inSeconds).round();
  }

  static String formatSecondToHHMM(int seconds) {
    if (seconds <= 0) return '0:00';
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();
    String hoursStr = (hours).toString();
    String minutesStr = (minutes).toString().padLeft(2, '0');
    return '$hoursStr:' '$minutesStr';
  }

  /// Formatted time: 8h30m -> 8:00
  static String convertHourString(String hour) {
    hour = hour.replaceAll(StringsApp.h, ':').replaceAll(StringsApp.m, '');
    return hour;
  }

  /// Parse time: '6:30 PM' -> '1970-01-01 18:30:00'
  static DateTime parseFromHmaString(String hourLabel) {
    return DateFormat('h:mm a').parse(hourLabel);
  }

  /// Format time: 2022-08-31 18:30:00 -> '6:30 PM'
  static String formatFromHmaString(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Formatted time: 01:30 -> 1h30m
  static String convertHourStrToHourLabel(String str) {
    final minutes = stringToInt(str);
    final hourString = '${(minutes ~/ 60)}${StringsApp.h}';
    final minuteString =
        '${(minutes % 60).toInt().toString().padLeft(2, '0')}${StringsApp.m}';
    return hourString + minuteString;
  }

  /// Formatted time: 1:30 -> 90
  static int stringToInt(String str) {
    final time = str.split(":");
    final hour = (double.tryParse(time.first) ?? 0).toInt();
    final minute = (double.tryParse(time.last) ?? 0).toInt();
    return hour * 60 + minute;
  }

  /// Formatted time: String 7:30 -> DateTime 2022-08-31 07:30:00
  static DateTime convertStringHourToDatetime(String timeStr) {
    final now = DateTime.now();
    final time = timeStr.split(":");
    DateTime timeDefault = DateTime(now.year, now.month, now.day,
        int.parse(time.first), int.parse(time.last));
    return timeDefault;
  }

  /// Formatted time: DateTime 2022-08-31 07:30:00  ->  String 7:30
  static String convertDatetimeToHourString(DateTime time) {
    return "${time.hour}:${time.minute}";
  }

  // Random 1-998
  static int generateRandomMillis() {
    return (Random().nextDouble() * 998).ceil();
  }

  // Using "difference" method has bug
  // https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static String generateShortDateTimeFormat(DateTime dateTime) {
    final now = DateTime.now();
    if (!now.isAfter(dateTime.add(const Duration(minutes: 1)))) {
      return StringsApp.justNow;
    } else if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return formatFromHmaString(dateTime);
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }

  static String getDurationFormat(int firstValueInt, int secondeValueInt) {
    var str = "";
    if (firstValueInt == 0 && secondeValueInt == 0) {
      str = "0";
    } else {
      str =
          "${firstValueInt == 0 ? "" : "$firstValueInt h"} ${secondeValueInt == 0 ? "" : "$secondeValueInt min"}";
    }

    return str;
  }

  static List<String> createListHours() {
    return List<String>.generate(24, (index) => index.toString());
  }

  static List<String> createListMinutes() {
    return List<String>.generate(60, (index) => index.toString());
  }

  ///xd xxh xxm | xh xxm
  static String formatStudyRemainingTime(int minutes) {
    if (minutes < 0) {
      return '';
    }

    final d = minutes ~/ (24 * 60);
    final h = (minutes - (d * 24 * 60)) ~/ 60;
    final m = minutes - d * 24 * 60 - h * 60;

    if (d > 0) {
      return '${d}d ${h > 9 ? h : '0$h'}${StringsApp.h} ${m > 9 ? m : '0$m'}${StringsApp.m}'; //xd xxh xxm
    }

    return '$h${StringsApp.h} ${m > 9 ? m : '0$m'}${StringsApp.m}'; // xh xxm
  }

  /// 0s < time < 1m    ==> "Just now"
  /// 1m = time         ==> "1 minute ago"
  /// 1m < time < 1h    ==> "59 minutes ago"
  /// 1h = time         ==> "1 hour ago"
  /// 1h < time < 24h   ==> "23 hours ago"
  /// 24h = time        ==> "1 day ago"
  /// 24h < time < 7d   ==> "6 days ago"
  /// time >= 7d        ==> "MM/DD/YYYY"
  // static String formatNotificationsTime(DateTime? dateTime) {
  //   final now = DateTime.now();
  //   if (dateTime == null) {
  //     return "-";
  //   }
  //   Duration differenceInDateTime = now.difference(dateTime);
  //   int differenceInDays = differenceInDateTime.inDays;
  //   int differenceInHours = differenceInDateTime.inHours;
  //   int differenceInMinutes = differenceInDateTime.inMinutes;
  //   int differenceInSeconds = differenceInDateTime.inSeconds;
  //   if (differenceInDays >= 7) {
  //     return dateTime.toMMslDDslYYYYFormat;
  //   }
  //   if (differenceInDays > 1) {
  //     return StringsApp.valueDaysAgo
  //         .replaceAll(StringsApp.replaceValue, '$differenceInDays');
  //   }
  //   if (differenceInDays == 1 || differenceInHours == 24) {
  //     return StringsApp.oneDayAgo;
  //   }
  //   if (differenceInHours > 1) {
  //     return StringsApp.valueHoursAgo
  //         .replaceAll(StringsApp.replaceValue, '$differenceInHours');
  //   }
  //   if (differenceInHours == 1 || differenceInMinutes == 60) {
  //     return StringsApp.oneHourAgo;
  //   }
  //   if (differenceInMinutes > 1) {
  //     return StringsApp.valueMinutesAgo
  //         .replaceAll(StringsApp.replaceValue, '$differenceInMinutes');
  //   }
  //   if (differenceInMinutes == 1 || differenceInSeconds == 60) {
  //     return StringsApp.oneMinuteAgo;
  //   }
  //   return StringsApp.justNow;
  // }

  /// 0s < time < 1m    ==> "Just now"
  /// 1m = time         ==> "1m ago"
  /// 1m < time < 1h    ==> "59m ago"
  /// 1h = time         ==> "1h ago"
  /// 1h < time < 24h   ==> "23h ago"
  /// 24h = time        ==> "1 day ago"
  /// 24h < time < 7d   ==> "6 days ago"
  /// time >= 7d        ==> "MM/DD/YYYY"
  // static String formatDeviceLastConnectedTime(DateTime? dateTime) {
  //   final now = DateTime.now();
  //   if (dateTime == null) {
  //     return "-";
  //   }
  //   Duration differenceInDateTime = now.difference(dateTime);
  //   int differenceInDays = differenceInDateTime.inDays;
  //   int differenceInHours = differenceInDateTime.inHours;
  //   int differenceInMinutes = differenceInDateTime.inMinutes;
  //   int differenceInSeconds = differenceInDateTime.inSeconds;
  //   if (differenceInDays >= 7) {
  //     return dateTime.toMMslDDslYYYYFormat;
  //   }
  //   if (differenceInDays > 1) {
  //     return StringsApp.valueDaysAgo
  //         .replaceAll(StringsApp.replaceValue, '$differenceInDays');
  //   }
  //   if (differenceInDays == 1 || differenceInHours == 24) {
  //     return StringsApp.oneDayAgo;
  //   }
  //   if (differenceInHours > 1) {
  //     return StringsApp.valueHoursAgoShort
  //         .replaceAll(StringsApp.replaceValue, '$differenceInHours');
  //   }
  //   if (differenceInHours == 1 || differenceInMinutes == 60) {
  //     return StringsApp.oneHourAgoShort;
  //   }
  //   if (differenceInMinutes > 1) {
  //     return StringsApp.valueMinutesAgoShort
  //         .replaceAll(StringsApp.replaceValue, '$differenceInMinutes');
  //   }
  //   if (differenceInMinutes == 1 || differenceInSeconds == 60) {
  //     return StringsApp.oneMinuteAgoShort;
  //   }
  //   return StringsApp.justNow;
  // }

  static String formatDeviceStatusTime(int time) {
    if (time == 120) {
      return StringsApp.activeValueHAgo
          .replaceAll(StringsApp.replaceValue, '2');
    }
    if (time >= 60) {
      return StringsApp.activeValueHAgo
          .replaceAll(StringsApp.replaceValue, '1');
    }
    if (time == 0) {
      return StringsApp.activeValueMAgo
          .replaceAll(StringsApp.replaceValue, '1');
    }
    return StringsApp.activeValueMAgo
        .replaceAll(StringsApp.replaceValue, '$time');
  }

  static String getTimeZoneLocation() {
    return tz.TZDateTime.now(tz.local).location.toString();
  }

  /// Keep hour, minutes, second as current time but change day, month, year as target date
  static DateTime mergeDateWithCurrentTime({
    DateTime? currentTime,
    DateTime? targetDate,
  }) {
    final current = currentTime ?? DateTime.now();
    final target = targetDate ?? DateTime.now();
    final dateResult = DateTime(
      target.year,
      target.month,
      target.day,
      current.hour,
      current.minute,
      current.second,
    );

    return dateResult;
  }

  // start, stop in millisecond
  static String? convertEpochToHHmmss(double? start, double? stop) {
    if (start == null || stop == null) {
      return null;
    }
    int differenceInSeconds = (stop / 1000 - start / 1000).toInt();
    int h, m, s;
    h = differenceInSeconds ~/ 3600;
    m = ((differenceInSeconds - h * 3600)) ~/ 60;
    s = differenceInSeconds - (h * 3600) - (m * 60);
    String hh, mm, ss;
    hh = h.toString().padLeft(2, '0');
    mm = m.toString().padLeft(2, '0');
    ss = s.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  static DateTime fromTimestamp(int int) =>
      DateTime.fromMillisecondsSinceEpoch(int);

  static int toTimestamp(DateTime? time) {
    return time?.millisecondsSinceEpoch ?? 0;
  }

  static String formatSecondToMss(int seconds) {
    if (seconds != 0) {
      int minutes = (seconds / 60).truncate();
      int second = (seconds % 60).truncate();

      String minutesStr = (minutes).toString();
      String secondStr = (second).toString().padLeft(2, '0');

      return '$minutesStr:' '$secondStr';
    } else {
      return "0:00";
    }
  }

  static DateTime min(DateTime date1, DateTime date2) {
    if (date1.isSameOrAfter(date2)) {
      return date2;
    } else {
      return date1;
    }
  }

  static DateTime max(DateTime date1, DateTime date2) {
    if (date1.isSameOrAfter(date2)) {
      return date1;
    } else {
      return date2;
    }
  }

  // Same date => Jun 04, 2022
  // Others => Jun 04 - Jun 10, 2023
  // static String getStartStop(DateTime date1, DateTime date2) {
  //   if (date1.isSameMomentIn(otherTime: date2, sameIn: TimeDurationEnum.day)) {
  //     return date1.toMMMddcmYYYYFormat;
  //   }

  //   final startDate = date1.toMMMddFormat;
  //   final endDate = date2.toMMMddcmYYYYFormat;
  //   return '$startDate - $endDate';
  // }

  static DateTime timeInMinute(DateTime time) {
    return DateTime(time.year, time.month, time.day, time.hour, time.minute);
  }
}
