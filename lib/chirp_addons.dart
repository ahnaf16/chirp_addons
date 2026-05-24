/// Addons for integrating [chirp](https://pub.dev/packages/chirp) with Dio
/// and structured JSON log rendering.
///
/// Exported APIs cover:
/// - [ChirpDioInterceptor] for automatic Dio request, response, and error logs
/// - [DioChirpFormatter] for rendering Dio objects inside a `ChirpLogger`
/// - [DioChirpConfig] for formatter behavior and color customization
/// - [ChirpPrettyJsonFormatter] for general-purpose pretty JSON logs
/// - [PrettyJsonSpan] for rendering nested structured payloads
library;

export 'src/chirp_dio_interceptor.dart';
export 'src/chirp_pretty_json_formatter.dart';
export 'src/dio_chirp_config.dart';
export 'src/dio_chirp_formatter.dart';
export 'src/pretty_json_span.dart';
