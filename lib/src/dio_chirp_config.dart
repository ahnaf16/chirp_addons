// ignore_for_file: experimental_member_use

import 'package:chirp/chirp.dart';

/// Configuration for [DioChirpFormatter] and [PrettyJsonSpan].
///
/// This controls which parts of a Dio transaction are logged, whether payloads
/// are pretty-printed, which fields are masked, and which colors are used in
/// console output.
class DioChirpConfig {
  /// Creates immutable logging configuration for Dio-related formatting.
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
    this.maskedHeaders = const {
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
      'token',
    },
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

  /// Whether outgoing requests should be logged.
  final bool logRequest;

  /// Whether successful responses should be logged.
  final bool logResponse;

  /// Whether Dio exceptions should be logged.
  final bool logError;

  /// Whether request headers should be included in request logs.
  final bool logRequestHeaders;

  /// Whether response headers should be included in response logs.
  final bool logResponseHeaders;

  /// Whether request bodies should be included in request logs.
  final bool logRequestBody;

  /// Whether response bodies should be included in response logs.
  final bool logResponseBody;

  /// Whether bodies should use [PrettyJsonSpan] instead of plain text output.
  final bool usePrettyJson;

  /// Whether to emit a shorter one-line oriented layout.
  final bool compact;

  /// Headers that should be hidden.
  final Set<String> maskedHeaders;

  /// Whether values in [maskedHeaders] should be replaced with `******`.
  final bool shouldMaskedHeaders;

  /// Path prefixes whose request or response bodies should be hidden.
  final Set<String> maskedRequestBody;

  /// Custom matcher that decides whether bodies for a given request [Uri]
  /// should be hidden.
  ///
  /// When omitted, [defaultReqBodyMasker] is used.
  final bool Function(Uri uri)? shouldMaskedRequestBody;

  /// Color used for request section borders and headings.
  final ConsoleColor requestColor;

  /// Color used for response section borders and headings.
  final ConsoleColor responseColor;

  /// Color used for error section borders and headings.
  final ConsoleColor errorColor;

  /// Color used for JSON object keys and header keys.
  final ConsoleColor headerKeyColor;

  /// Color used for string values.
  final ConsoleColor stringColor;

  /// Color used for numeric values.
  final ConsoleColor numberColor;

  /// Color used for boolean values.
  final ConsoleColor boolColor;

  /// Color used for `null` values.
  final ConsoleColor nullColor;

  /// Color used for labels such as `Method:` or `Headers:`.
  final ConsoleColor labelColor;

  /// Reserved color for timestamps in related formatters.
  final ConsoleColor timestampColor;

  /// If the [Uri.path] starts with any of [maskedRequestBody], the request body will be hidden.
  ///
  /// Returns `true` when any configured path prefix matches [uri].
  static bool defaultReqBodyMasker(Uri uri, Set<String> maskedRequestBody) {
    final path = uri.path;
    return maskedRequestBody.any((e) => path.startsWith(e));
  }
}
