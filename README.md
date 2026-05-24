# chirp_addons

`chirp_addons` extends [`chirp`](https://pub.dev/packages/chirp) with two focused capabilities:

- Dio request, response, and exception logging through a dedicated interceptor
- Pretty JSON and structured payload rendering for richer console output

The package is small by design. It does not replace `chirp`; it plugs into `chirp`'s formatter and writer system so you can keep one logging stack for application events and HTTP traffic.

## Features

- `ChirpDioInterceptor` for automatic Dio lifecycle logging
- `DioChirpFormatter` for rendering `RequestOptions`, `Response`, and `DioException`
- `DioChirpConfig` for masking, compact mode, toggles, and colors
- `ChirpPrettyJsonFormatter` for readable structured logs outside Dio
- `PrettyJsonSpan` for maps, lists, `FormData`, and `MultipartFile`

## Installation

Add the package and its peer dependencies:

```yaml
dependencies:
  chirp: ^0.9.0
  dio: ^5.9.2
  chirp_addons: ^0.0.1
```

Then fetch packages:

```bash
flutter pub get
```

## How It Extends chirp

`chirp` provides the logger, levels, writers, and formatter abstractions. `chirp_addons` adds Dio-aware formatters and interceptors on top of those primitives:

- `ChirpDioInterceptor` sends Dio objects into a `ChirpLogger`
- `DioChirpFormatter` detects Dio types and formats them into colored spans
- `ChirpPrettyJsonFormatter` improves general structured logs for non-HTTP use cases
- `PrettyJsonSpan` is the shared renderer for nested data and multipart payloads

## Quick Start

Use the built-in Dio logger:

```dart
import 'package:chirp_addons/chirp_addons.dart';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.interceptors.add(ChirpDioInterceptor(chirpDioLogger));

  await dio.get('https://example.com/users', queryParameters: {'page': 1});
}
```

## Dio Integration

Use a custom `ChirpLogger` when you want control over output writers or formatter configuration:

```dart
import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';
import 'package:dio/dio.dart';

final dioLogger = ChirpLogger(name: 'HTTP')
  ..addConsoleWriter(
    output: log,
    formatter: DioChirpFormatter(
      config: const DioChirpConfig(
        logResponseHeaders: true,
        shouldMaskedHeaders: true,
        maskedHeaders: {'authorization', 'x-api-key'},
      ),
    ),
  );

void main() {
  final dio = Dio();
  dio.interceptors.add(ChirpDioInterceptor(dioLogger));
}
```

## Pretty JSON Logging

For non-Dio logs, attach `ChirpPrettyJsonFormatter` to a logger or the root logger:

```dart
import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';

void main() {
  final logger = ChirpLogger(name: 'APP')
    ..addConsoleWriter(
      output: log,
      formatter: ChirpPrettyJsonFormatter(getCallerInfo: false),
    );

  logger.info(
    'User payload',
    data: {
      'id': 42,
      'name': 'Ahnaf',
      'roles': ['admin', 'editor'],
      'flags': {'emailVerified': true, 'beta': false},
    },
  );
}
```

## Example Output

Representative console output:

```text
──────────────────────────────────────────────────
HTTP REQUEST
Method:      POST
URL:         https://api.example.com/login

Headers:
{
  authorization: "******",
  content-type: "application/json"
}

Body:
{
  email: "user@example.com",
  password: "******"
}
──────────────────────────────────────────────────
```

Exact colors depend on your writer, terminal, and `DioChirpConfig`.

## Configuration

`DioChirpConfig` is the main customization point.

Common options:

- `logRequest`, `logResponse`, `logError` toggle whole event categories
- `logRequestHeaders`, `logResponseHeaders` control header sections
- `logRequestBody`, `logResponseBody` control payload sections
- `usePrettyJson` switches between structured rendering and plain text
- `compact` emits a tighter layout with less metadata
- `maskedHeaders` and `shouldMaskedHeaders` redact sensitive headers
- `maskedRequestBody` and `shouldMaskedRequestBody` suppress body logging for matching routes
- `requestColor`, `responseColor`, `errorColor`, and value colors customize appearance

Example:

```dart
const config = DioChirpConfig(
  compact: true,
  shouldMaskedHeaders: true,
  maskedHeaders: {'authorization', 'cookie'},
  maskedRequestBody: {'/auth/login', '/payments'},
  logResponseHeaders: true,
);
```

## API Overview

Public API exported by `package:chirp_addons/chirp_addons.dart`:

- `chirpDioLogger`: ready-made `ChirpLogger` configured for Dio logging
- `ChirpDioInterceptor`: Dio interceptor that forwards lifecycle objects to a logger
- `DioChirpFormatter`: formatter for `RequestOptions`, `Response`, and `DioException`
- `DioChirpConfig`: immutable options for masking, display, and colors
- `ChirpPrettyJsonFormatter`: general structured log formatter
- `PrettyJsonSpan`: low-level reusable pretty-printer for nested values
- `CompactFormatOptions`: compatibility subtype of `FormatOptions`

## Examples

A runnable Flutter demo app lives in [`example/`](example). It includes:

- basic structured logging
- pretty JSON logging with caller info
- Dio interceptor request and response logging
- custom configuration with masked headers and auth-error logging

Run it with:

```bash
cd example
flutter pub get
flutter run
```

## Best Practices

- Reuse a single `ChirpLogger` for HTTP traffic instead of creating one per request
- Mask secrets such as authorization headers and login endpoints
- Keep `getCallerInfo` disabled in production unless source locations are required
- Use `compact: true` for noisy environments and full formatting during debugging
- Prefer `ChirpPrettyJsonFormatter` for app/domain logs and `DioChirpFormatter` for transport logs

## Troubleshooting

### No Dio logs appear

Confirm that:

- the interceptor was added to `dio.interceptors`
- the logger has at least one writer
- the writer output is visible in the current runtime

### Sensitive headers are still visible

Header masking only applies when `shouldMaskedHeaders` is `true`. Also ensure header names are provided in lowercase or match after `.toLowerCase()`.

### Request or response bodies are too noisy

Use one or more of:

- `compact: true`
- `logRequestBody: false`
- `logResponseBody: false`
- `maskedRequestBody` or `shouldMaskedRequestBody`

### Caller info affects performance

`ChirpPrettyJsonFormatter(getCallerInfo: true)` causes stack trace capture on every log call. Leave it `false` unless file and line metadata are needed.

## Contributing

1. Keep changes backward compatible unless the version is intentionally bumped for a breaking release.
2. Add or update API docs and examples when changing public behavior.
3. Run formatting and static analysis before opening a pull request.

## License

This project is licensed under the terms of the [MIT License](LICENSE).
