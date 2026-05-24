import 'dart:convert';
import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ExampleController extends ChangeNotifier {
  static final RegExp _ansiEscapePattern = RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]');

  final List<String> _entries = [];

  final List<ExampleDefinition> examples = const [
    ExampleDefinition(
      id: ExampleId.basicLogging,
      title: 'Basic logging',
      description:
          'Formats a regular chirp log record with nested data using the package JSON formatter.',
      highlights: ['ChirpPrettyJsonFormatter', 'Structured data', 'No Dio'],
    ),
    ExampleDefinition(
      id: ExampleId.prettyJson,
      title: 'Pretty JSON logging',
      description:
          'Shows a richer nested payload and includes caller metadata in the formatted output.',
      highlights: ['Caller info', 'Maps and lists', 'Readable output'],
    ),
    ExampleDefinition(
      id: ExampleId.dioSuccess,
      title: 'Dio interceptor logging',
      description:
          'Runs a successful mock HTTP request and logs the request and response through ChirpDioInterceptor.',
      highlights: ['Request log', 'Response log', 'Mock adapter'],
    ),
    ExampleDefinition(
      id: ExampleId.customConfig,
      title: 'Custom configuration',
      description:
          'Applies header masking and response-body suppression for a simulated auth endpoint.',
      highlights: ['Masked headers', 'Custom config', 'Error flow'],
    ),
  ];

  bool _isBusy = false;
  ExampleId? _activeExampleId;

  List<String> get entries => List.unmodifiable(_entries);
  bool get isBusy => _isBusy;
  ExampleId? get activeExampleId => _activeExampleId;

  Future<void> runExample(ExampleId id) async {
    if (_isBusy) return;

    _isBusy = true;
    _activeExampleId = id;
    _appendDivider();
    _appendPlain('Running ${_labelFor(id)}');
    notifyListeners();

    try {
      switch (id) {
        case ExampleId.basicLogging:
          _runBasicLogging();
        case ExampleId.prettyJson:
          _runPrettyJsonLogging();
        case ExampleId.dioSuccess:
          await _runDioInterceptorLogging();
        case ExampleId.customConfig:
          await _runCustomConfiguration();
      }
    } finally {
      _isBusy = false;
      _activeExampleId = null;
      notifyListeners();
    }
  }

  void clearLogs() {
    _entries.clear();
    notifyListeners();
  }

  void _runBasicLogging() {
    _buildPrettyLogger(name: 'BASIC', getCallerInfo: false).info(
      'Application started',
      data: {
        'environment': 'development',
        'features': ['dio-logging', 'pretty-json'],
        'debug': true,
      },
    );
  }

  void _runPrettyJsonLogging() {
    _buildPrettyLogger(name: 'JSON', getCallerInfo: true).success(
      'Fetched profile payload',
      data: {
        'user': {'id': 7, 'name': 'Taylor', 'emailVerified': true},
        'permissions': ['read', 'write'],
        'metadata': {'source': 'cache', 'latencyMs': 12},
      },
    );
  }

  Future<void> _runDioInterceptorLogging() async {
    final logger = _buildDioLogger(name: 'HTTP');
    final dio = _buildDio(logger);

    await dio.get(
      '/posts/1',
      queryParameters: {'include': 'author,comments', 'page': 1},
      options: Options(headers: {'x-demo-mode': 'success'}),
    );
  }

  Future<void> _runCustomConfiguration() async {
    final logger = _buildDioLogger(
      name: 'SECURE_HTTP',
      config: const DioChirpConfig(
        logResponseHeaders: true,
        shouldMaskedHeaders: true,
        maskedHeaders: {'authorization', 'x-api-key'},
        maskedRequestBody: {'/auth/login'},
      ),
    );

    final dio = _buildDio(logger);

    try {
      await dio.post(
        '/auth/login',
        data: {'email': 'dev@example.com', 'password': 'secret'},
        options: Options(
          headers: {'authorization': 'Bearer token', 'x-api-key': 'demo-key'},
        ),
      );
    } on DioException catch (error) {
      _appendPlain(
        'Handled DioException: ${error.response?.statusCode ?? error.type.name}',
      );
    }
  }

  Dio _buildDio(ChirpLogger logger) {
    final dio = Dio(BaseOptions(baseUrl: _MockHttpClientAdapter.baseUrl));
    dio
      ..httpClientAdapter = _MockHttpClientAdapter()
      ..interceptors.add(ChirpDioInterceptor(logger));
    return dio;
  }

  ChirpLogger _buildPrettyLogger({
    required String name,
    required bool getCallerInfo,
  }) {
    return ChirpLogger(name: name)..addConsoleWriter(
      output: _write,
      formatter: ChirpPrettyJsonFormatter(getCallerInfo: getCallerInfo),
    );
  }

  ChirpLogger _buildDioLogger({
    required String name,
    DioChirpConfig config = const DioChirpConfig(),
  }) {
    return ChirpLogger(name: name)..addConsoleWriter(
      output: _write,
      formatter: DioChirpFormatter(config: config),
    );
  }

  void _write(String message) {
    log(message);
    _entries.add(_stripAnsi(message));
    notifyListeners();
  }

  void _appendPlain(String message) {
    _entries.add(message);
    notifyListeners();
  }

  void _appendDivider() {
    if (_entries.isEmpty) {
      return;
    }

    _entries.add(List.filled(72, '═').join());
  }

  String _labelFor(ExampleId id) {
    return switch (id) {
      ExampleId.basicLogging => 'Basic logging',
      ExampleId.prettyJson => 'Pretty JSON logging',
      ExampleId.dioSuccess => 'Dio interceptor logging',
      ExampleId.customConfig => 'Custom configuration',
    };
  }

  String _stripAnsi(String message) {
    return message.replaceAll(_ansiEscapePattern, '');
  }
}

enum ExampleId { basicLogging, prettyJson, dioSuccess, customConfig }

class ExampleDefinition {
  const ExampleDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.highlights,
  });

  final ExampleId id;
  final String title;
  final String description;
  final List<String> highlights;
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  static const baseUrl = 'https://demo.chirp.dev';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return switch (options.path) {
      '/posts/1' => ResponseBody.fromString(
        jsonEncode({
          'id': 1,
          'title': 'Hello from chirp_addons',
          'author': {'id': 9, 'name': 'Dio Adapter'},
          'comments': 12,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'x-request-id': ['demo-success-001'],
        },
      ),
      '/auth/login' => ResponseBody.fromString(
        jsonEncode({
          'error': 'invalid_credentials',
          'message': 'The provided credentials are invalid.',
        }),
        401,
        statusMessage: 'Unauthorized',
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'set-cookie': ['session=secret'],
        },
      ),
      _ => ResponseBody.fromString(
        jsonEncode({'error': 'not_found'}),
        404,
        statusMessage: 'Not Found',
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    };
  }

  @override
  void close({bool force = false}) {}
}
