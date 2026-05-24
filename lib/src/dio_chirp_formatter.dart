// ignore_for_file: experimental_member_use

import 'package:chirp/chirp.dart';
import 'package:chirp/chirp_spans.dart';
import 'package:chirp_addons/src/dio_chirp_config.dart';
import 'package:chirp_addons/src/pretty_json_span.dart';
import 'package:dio/dio.dart';

class DioChirpFormatter extends SpanBasedFormatter {
  DioChirpFormatter({this.config = const DioChirpConfig()});

  final DioChirpConfig config;

  SpanSequence _logRequest(RequestOptions opt) {
    return SpanSequence(
      children: [
        _line(config.requestColor, true),
        _header('HTTP REQUEST', config.requestColor),

        _row('Method', opt.method),
        _row('URL', opt.uri.toString()),

        if (!config.compact) ...[
          _row('Connect', '${opt.connectTimeout?.inMilliseconds ?? 0}ms'),
          _row('Receive', '${opt.receiveTimeout?.inMilliseconds ?? 0}ms'),
        ],

        /// HEADERS
        if (config.logRequestHeaders && opt.headers.isNotEmpty) ...[
          NewLine(),
          _sectionTitle('Headers'),
          NewLine(),
          config.compact ? InlineData(opt.headers) : PrettyJsonSpan(_sanitizeHeaders(opt.headers), config: config),
          NewLine(),
        ],

        /// QUERY PARAMS
        if (opt.queryParameters.isNotEmpty) ...[
          NewLine(),
          _sectionTitle('Query'),
          NewLine(),
          config.compact ? InlineData(opt.queryParameters) : PrettyJsonSpan(opt.queryParameters, config: config),
          NewLine(),
        ],

        /// BODY
        if (config.logRequestBody && !_isNullOrEmpty(opt.data)) ...[
          NewLine(),
          _sectionTitle('Body'),
          NewLine(),
          _buildBody(opt.data),
        ],
        _line(config.requestColor, false),
      ],
    );
  }

  SpanSequence _logResponse(Response res) {
    final uri = res.requestOptions.uri;
    final maskBody =
        config.shouldMaskedRequestBody?.call(uri) ?? DioChirpConfig.defaultReqBodyMasker(uri, config.maskedRequestBody);

    final isError = (res.statusCode ?? 0) >= 400;

    final color = isError ? config.errorColor : config.responseColor;

    return SpanSequence(
      children: [
        _line(color, true),
        _header(isError ? 'HTTP ERROR RESPONSE' : 'HTTP RESPONSE', color),

        _row('Status', '${res.statusCode} ${res.statusMessage ?? ''}'),
        _row('Method', res.requestOptions.method),
        _row('URL', res.requestOptions.uri.toString()),

        if (!config.compact) _row('Redirect', '${res.isRedirect}'),

        /// RESPONSE HEADERS
        if (config.logResponseHeaders && res.headers.map.isNotEmpty) ...[
          NewLine(),
          _sectionTitle('Headers'),
          NewLine(),
          config.compact || maskBody
              ? InlineData(res.headers.map)
              : PrettyJsonSpan(_sanitizeHeaders(res.headers.map), config: config),
          NewLine(),
        ],

        /// DATA
        if (config.logResponseBody && !_isNullOrEmpty(res.data) && !maskBody) ...[
          NewLine(),
          _sectionTitle('Data'),
          NewLine(),
          _buildBody(res.data),
        ],
        _line(color, false),
      ],
    );
  }

  SpanSequence _logDioError(DioException err) {
    return SpanSequence(
      children: [
        _line(config.errorColor, true),
        _header('DIO EXCEPTION', config.errorColor),

        _row('Type', err.type.name),
        _row('Message', err.message ?? 'Unknown'),
        _row('URL', err.requestOptions.uri.toString()),

        if (err.response case final Response r) ...[
          _row('Status', '${r.statusCode}'),
          if (r.statusMessage != null) _row('Status Message', r.statusMessage ?? ''),
          if (r.data != null) ...[NewLine(), _sectionTitle('Response Data'), NewLine(), _buildBody(r.data)],
        ],

        if (err.error != null) ...[NewLine(), _sectionTitle('Error'), NewLine(), PlainText(err.error.toString())],

        if (!config.compact) ...[
          NewLine(),
          _sectionTitle('Stacktrace'),
          NewLine(),
          AnsiStyled(foreground: Ansi16.brightBlack, child: StackTraceSpan(err.stackTrace)),
        ],
        _line(config.errorColor, false),
      ],
    );
  }

  @override
  LogSpan buildSpan(LogRecord record) {
    final data = record.message;

    if (data case final RequestOptions opt) {
      if (!config.logRequest) return EmptySpan();
      return _logRequest(opt);
    }

    if (data case final Response res) {
      if (!config.logResponse) return EmptySpan();
      return _logResponse(res);
    }

    if (data case final DioException err) {
      if (!config.logError) return EmptySpan();

      return _logDioError(err);
    }

    /// FALLBACK
    return RainbowMessageFormatter().buildSpan(record);
  }

  // HELPERS  ------------------------------------------------------------

  LogSpan _line(ConsoleColor color, bool isTop) {
    return AnsiStyled(
      foreground: color,
      child: Surrounded(suffix: NewLine(), prefix: isTop ? null : NewLine(), child: PlainText('─' * 50)),
    );
  }

  LogSpan _buildBody(dynamic body) {
    if (config.usePrettyJson) return PrettyJsonSpan(body, config: config);
    return PlainText(body.toString());
  }

  Map<String, dynamic> _sanitizeHeaders(Map<dynamic, dynamic> headers) {
    return headers.map((key, value) {
      final k = key.toString();
      final shouldMask = config.shouldMaskedHeaders && config.maskedHeaders.contains(k.toLowerCase());
      return MapEntry(k, shouldMask ? '******' : value);
    });
  }

  bool _isNullOrEmpty(dynamic x) {
    return switch (x) {
      null => true,
      final String s when s.isEmpty => true,
      final Iterable i when i.isEmpty => true,
      final Map m when m.isEmpty => true,
      _ => false,
    };
  }

  LogSpan _header(String text, ConsoleColor color) {
    return SpanSequence(
      children: [
        AnsiStyled(foreground: color, bold: true, child: PlainText(text)),
        NewLine(),
      ],
    );
  }

  LogSpan _sectionTitle(String text) {
    return AnsiStyled(dim: true, foreground: config.labelColor, child: PlainText('$text:'));
  }

  LogSpan _row(String label, String value) {
    return SpanSequence(
      children: [
        Aligned(
          width: 12,
          align: HorizontalAlign.left,
          child: AnsiStyled(foreground: config.labelColor, dim: true, child: PlainText('$label:')),
        ),
        PlainText(value),
        NewLine(),
      ],
    );
  }
}
