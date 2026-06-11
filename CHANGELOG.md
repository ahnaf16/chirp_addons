# Change Log

## 0.0.2

- Moved log level display next to the timestamp for better visual alignment in `ChirpPrettyJsonFormatter`.
- Added formatting and rendering for error objects and stack traces for log records at `error` level or higher.
- Cleaned up line formatting and code structure in `ChirpPrettyJsonFormatter`.

## 0.0.1

Initial release of `chirp_addons`.

- Added `ChirpDioInterceptor` for Dio request, response, and exception logging
- Added `DioChirpFormatter` and `DioChirpConfig` for structured HTTP log formatting
- Added `ChirpPrettyJsonFormatter` and `PrettyJsonSpan` for readable JSON and nested payload output
- Added a ready-to-use `chirpDioLogger` and example app demonstrating package usage
