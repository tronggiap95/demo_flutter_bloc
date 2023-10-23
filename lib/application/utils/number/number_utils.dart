import 'dart:math';
import 'dart:typed_data';

import 'package:intl/intl.dart';

extension NumEx on double {
  /// n=1,  1.358 -> 1.4
  /// n=2,  1.358 -> 1.36
  double toPrecission(int n) => double.parse(toStringAsFixed(n));

  /// n=1,  1.358 -> 1.3
  /// n=2,  1.358 -> 1.35
  double truncateToDecimalPlaces(int fractionalDigits) =>
      (this * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
  double toRoundedPrecision(int n) =>
      double.parse(((this * 10 * n).round() / 10).toStringAsFixed(n));
}

class NumberUtils {
  static var format = NumberFormat(
    "###,###",
    "en_US",
  );

  static var workoutFormat = NumberFormat("###.#", "en_US");

  static String toWorkoutFormat(double value) {
    return workoutFormat.format(value);
  }

  static String toNum(double number) {
    return format.format(number);
  }

  static bool isDecimalStartWith0(num? value) {
    if (value == null) return false;
    return value is int ||
        num.parse(value.toStringAsFixed(1)) == value.roundToDouble();
  }

  static String formatDecimalNumber(double? value) {
    if (value == null) return '-';
    // round double before remove the first digit of decimal part
    final roundDouble = ((value * 10).round()) / 10;
    return roundDouble
        .toStringAsFixed(NumberUtils.isDecimalStartWith0(roundDouble) ? 0 : 1);
  }
}

extension Uint8ListExt on Uint8List {
  Int16List toInt16List() {
    List<int> list = [];
    for (int i = 0; i <= length - 2; i += 2) {
      list.add((this[i + 1] << 8) + this[i]);
    }
    return Int16List.fromList(list);
  }
}
