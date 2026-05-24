import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';
import 'package:dio/dio.dart';

void main() async {
  final logger = ChirpLogger(name: 'SECURE_HTTP')
    ..addConsoleWriter(
      output: log,
      formatter: DioChirpFormatter(
        config: const DioChirpConfig(
          compact: false,
          logResponseHeaders: true,
          shouldMaskedHeaders: true,
          maskedHeaders: {'authorization', 'x-api-key'},
          maskedRequestBody: {'/auth/login'},
        ),
      ),
    );

  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
    ..interceptors.add(ChirpDioInterceptor(logger));

  try {
    await dio.post(
      '/auth/login',
      data: {'email': 'dev@example.com', 'password': 'secret'},
      options: Options(
        headers: {'authorization': 'Bearer token', 'x-api-key': 'demo-key'},
      ),
    );
  } on DioException {
    // Ignore network failure in the example. The point is to demonstrate logging.
  }
}
