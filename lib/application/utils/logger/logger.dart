import 'package:logger/logger.dart';

class Log {
  static final logger = Logger();

  //Debug log
  static void d(dynamic message) {
    logger.d(message);
  }

  //Error log
  static void e(dynamic message) {
    logger.e(message);
  }

  //Info log
  static void i(dynamic message) {
    logger.i(message);
  }

  //warning log
  static void w(dynamic message) {
    logger.w(message);
  }

  //Error log long
  static void eWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => e(match.group(0)));
  }
}
