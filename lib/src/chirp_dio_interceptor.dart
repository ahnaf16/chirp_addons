// ignore_for_file: experimental_member_use
import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/src/dio_chirp_formatter.dart';
import 'package:dio/dio.dart';

/// Global Chirp Logger for Dio
///
/// ```dart
/// final _dio = Dio(options);
/// _dio.interceptors.add(ChirpDioInterceptor(chirpDioLogger));
/// ```
///
/// or use your own ChirpLogger
///
/// ```dart
/// final _dio = Dio(options);
/// final logger = ChirpLogger(name: 'DIO')
/// ..addConsoleWriter(output: (x) => debugPrint(x), formatter: DioChirpFormatter());
/// _dio.interceptors.add(ChirpDioInterceptor(logger));
/// ```
final chirpDioLogger = ChirpLogger(name: 'DIO')
  ..addConsoleWriter(output: (x) => log(x), formatter: DioChirpFormatter());

class ChirpDioInterceptor extends Interceptor {
  final ChirpLogger logger;

  ChirpDioInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.log(options, level: .debug);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.log(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.log(err, level: .error);
    handler.next(err);
  }
}

class CompactFormatOptions extends FormatOptions {}
