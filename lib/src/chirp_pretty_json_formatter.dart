// ignore_for_file: experimental_member_use

import 'package:chirp/chirp.dart';
import 'package:chirp/chirp_spans.dart';
import 'package:chirp_addons/src/pretty_json_span.dart';

class ChirpPrettyJsonFormatter extends SpanBasedFormatter {
  ChirpPrettyJsonFormatter({required this.getCallerInfo});

  /// Whether this formatter needs caller info (file, line, class, method).
  ///
  /// When `true`, the logger captures `StackTrace.current` on every log call,
  /// which is expensive. Only enable if the formatter displays source locations.
  final bool getCallerInfo;

  @override
  bool get requiresCallerInfo {
    return getCallerInfo;
  }

  @override
  LogSpan buildSpan(LogRecord record) {
    final callerInfo = record.callerInfo;
    final levelColor = _getLevelColor(record.level);
    final spans = [
      AnsiStyled(foreground: Ansi16.brightBlack, child: BracketedTimestamp(record.timestamp)),
      Whitespace(),
    ];

    // File name
    if (callerInfo != null) {
      final location = AnsiStyled(
        foreground: Ansi256.lightSkyBlue3_110,
        child: DartSourceCodeLocation(fileName: callerInfo.callerFileName, line: callerInfo.line),
      );

      spans.add(Surrounded(prefix: Whitespace(), suffix: Whitespace(), child: location));
    }

    // Class Name
    final className = ClassName.fromRecord(record, hashLength: 4);
    if (className != null) {
      final classNameSpan = AnsiStyled(
        foreground: colorForHash(className.name, saturation: .low),
        child: className,
      );
      spans.add(Surrounded(prefix: Whitespace(), suffix: Whitespace(), child: classNameSpan));
    }

    // Message
    spans.addAll([
      NewLine(),
      AnsiStyled(bold: true, foreground: levelColor, child: BracketedLogLevel(record.level)),
      Whitespace(),
      AnsiStyled(foreground: levelColor, bold: true, child: LogMessage(record.message)),
      NewLine(),
    ]);

    // Data
    if (record.data.isNotEmpty) spans.addAll([dimmed(PlainText('Data:')), Whitespace(), PrettyJsonSpan(record.data)]);

    return SpanSequence(children: spans);
  }

  ConsoleColor _getLevelColor(ChirpLogLevel level) {
    if (level > ChirpLogLevel.error) return Ansi256.indianRed1_203;
    if (level >= ChirpLogLevel.error) return Ansi256.indianRed_167;
    if (level > ChirpLogLevel.warning) return Ansi256.lightSalmon3_173;
    if (level >= ChirpLogLevel.warning) return Ansi256.lightGoldenrod3_179;
    if (level == ChirpLogLevel.success) return Ansi256.green_2;
    return Ansi256.white_7;
  }

  LogSpan dimmed(LogSpan span) {
    return AnsiStyled(dim: true, foreground: Ansi256.white_7, child: span);
  }
}
