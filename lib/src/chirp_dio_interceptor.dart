// ignore_for_file: experimental_member_use
import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/src/dio_chirp_formatter.dart';
import 'package:dio/dio.dart';

/// Global Chirp Logger for Dio
///
/// This logger is preconfigured with [DioChirpFormatter] and writes to
/// `dart:developer`'s [log] function.
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

/// A Dio [Interceptor] that routes request lifecycle events into a
/// [ChirpLogger].
///
/// The interceptor logs:
/// - [RequestOptions] on request
/// - [Response] on success
/// - [DioException] on failure
///
/// Pair this with [chirpDioLogger] for a ready-made setup, or pass a custom
/// logger configured with [DioChirpFormatter].
class ChirpDioInterceptor extends Interceptor {
  /// Creates an interceptor that logs Dio traffic with [logger].
  final ChirpLogger logger;

  /// Creates a new Dio logger interceptor.
  ChirpDioInterceptor(this.logger);

  /// Logs the outgoing [options] as a request event, then continues the chain.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.log(options, level: .debug);
    handler.next(options);
  }

  /// Logs the incoming [response], then continues the chain.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.log(response);
    handler.next(response);
  }

  /// Logs the Dio [err] as an error event, then continues the chain.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.log(err, level: .error);
    handler.next(err);
  }
}

/// Placeholder [FormatOptions] subtype for compact formatting compatibility.
///
/// This type currently behaves the same as [FormatOptions] and is kept for API
/// compatibility.
class CompactFormatOptions extends FormatOptions {}
