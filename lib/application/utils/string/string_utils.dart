import 'package:intl/intl.dart';

class StringUtils {
  static bool isNullOrEmpty(String? value) => value == null || value.isEmpty;

  static bool isNotNullOrEmpty(String? value) => !isNullOrEmpty(value);

  static String valueOrDefault(String value, String theDefault) =>
      isNotNullOrEmpty(value) ? value : theDefault;

  static String formatCurrency(String? value, {String symbol = '\$'}) {
    if (isNullOrEmpty(value)) {
      return '';
    }
    var numberFormat = NumberFormat.currency(
        locale: 'en_US', decimalDigits: 0, symbol: symbol);
    var numberRegExp = int.parse(value!.replaceAll(RegExp(r'[^0-9]'), ''));
    return numberFormat.format(numberRegExp).trim();
  }

  static int extractNumber(String? value) {
    if (isNullOrEmpty(value)) {
      return 0;
    }
    return int.parse(value!.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  static bool isNumeric(String s) {
    var numeric = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      return false;
    }
    return double.tryParse(numeric) != null;
  }

  static bool isEmail(String value) {
    if (isNullOrEmpty(value)) {
      return false;
    }

    String emailRegex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    return RegExp(emailRegex).hasMatch(value);
  }

  static bool isPhoneNumber(String value) {
    String phoneRegex = r'^(?:[+0]9)?[0-9]{10}$';
    if (isNotNullOrEmpty(value)) {
      return RegExp(phoneRegex).hasMatch(value);
    }
    return false;
  }

  static String toMergeParams(Map<String, String?> args) {
    String output = '';
    args.forEach((key, value) {
      output += isNullOrEmpty(value)
          ? ''
          : isNullOrEmpty(output)
              ? '$key=$value'
              : ',$key=$value';
    });
    return output;
  }

  static bool isIncludeLowercase(String text) {
    return text.contains(RegExp(r'[a-z]'));
  }

  static bool isIncludeUppercase(String text) {
    return text.contains(RegExp(r'[A-Z]'));
  }

  static bool isIncludeNumber(String text) {
    return text.contains(RegExp(r'[0-9]'));
  }

  static String? removeLastChar({String? text, String remove = '|'}) {
    if (text != null && text.endsWith(remove)) {
      return text.substring(0, text.length - 1);
    }
    return text;
  }

  static String? getFileNameInPath(String? path) {
    if (path == null) {
      return null;
    }
    List<String> pathComponents = path.split('/');
    return pathComponents.last;
  }
}
