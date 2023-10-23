import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  static Future<Dio> getDio(Map<String, String> headers,
      {ResponseType responseType = ResponseType.json,
      isPrintLog = false}) async {
    Dio dio = Dio();

    const timeout = Duration(minutes: 1); // 1 min

    dio.options = BaseOptions(
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: headers,
        responseType: responseType);

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        logPrint: (object) {
          if (isPrintLog) {
            if (kDebugMode) {
              print(object);
            }
          }
        },
      ));
    }

    return dio;
  }
}
