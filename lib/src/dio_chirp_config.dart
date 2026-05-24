// ignore_for_file: experimental_member_use

import 'package:chirp/chirp.dart';

class DioChirpConfig {
  const DioChirpConfig({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logRequestHeaders = true,
    this.logResponseHeaders = false,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.usePrettyJson = true,
    this.compact = false,
    this.maskedHeaders = const {'authorization', 'cookie', 'set-cookie', 'x-api-key', 'token'},
    this.shouldMaskedHeaders = false,
    this.maskedRequestBody = const {},
    this.shouldMaskedRequestBody,
    this.requestColor = Ansi16.brightBlue,
    this.responseColor = Ansi16.brightGreen,
    this.errorColor = Ansi16.brightRed,
    this.headerKeyColor = Ansi16.brightCyan,
    this.stringColor = Ansi16.brightYellow,
    this.numberColor = Ansi16.brightGreen,
    this.boolColor = Ansi16.brightMagenta,
    this.nullColor = Ansi16.brightBlack,
    this.labelColor = Ansi16.brightWhite,
    this.timestampColor = Ansi16.brightBlack,
  });

  final bool logRequest;
  final bool logResponse;
  final bool logError;

  final bool logRequestHeaders;
  final bool logResponseHeaders;

  final bool logRequestBody;
  final bool logResponseBody;

  final bool usePrettyJson;
  final bool compact;

  /// Headers that should be hidden.
  final Set<String> maskedHeaders;
  final bool shouldMaskedHeaders;

  /// Request bodies that should be hidden.
  final Set<String> maskedRequestBody;
  final bool Function(Uri uri)? shouldMaskedRequestBody;

  /// Colors
  final ConsoleColor requestColor;
  final ConsoleColor responseColor;
  final ConsoleColor errorColor;

  final ConsoleColor headerKeyColor;

  final ConsoleColor stringColor;
  final ConsoleColor numberColor;
  final ConsoleColor boolColor;
  final ConsoleColor nullColor;

  final ConsoleColor labelColor;
  final ConsoleColor timestampColor;

  /// If the [Uri.path] starts with any of [maskedRequestBody], the request body will be hidden.
  static bool defaultReqBodyMasker(Uri uri, Set<String> maskedRequestBody) {
    final path = uri.path;
    return maskedRequestBody.any((e) => path.startsWith(e));
  }
}
