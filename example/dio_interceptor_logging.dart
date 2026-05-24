import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';
import 'package:dio/dio.dart';

void main() async {
  final dioLogger = ChirpLogger(name: 'HTTP')
    ..addConsoleWriter(output: log, formatter: DioChirpFormatter());

  final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'))
    ..interceptors.add(ChirpDioInterceptor(dioLogger));

  await dio.get('/posts/1');
}
