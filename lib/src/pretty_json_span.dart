// ignore_for_file: experimental_member_use

import 'package:chirp/chirp.dart';
import 'package:chirp/chirp_spans.dart';
import 'package:chirp_addons/src/dio_chirp_config.dart';
import 'package:dio/dio.dart';

/// A reusable chirp span that pretty-prints structured values.
///
/// Supported inputs include:
/// - maps
/// - lists
/// - Dio [FormData]
/// - Dio [MultipartFile]
/// - scalar values such as strings, numbers, and booleans
///
/// This span is used internally by [DioChirpFormatter] and
/// [ChirpPrettyJsonFormatter], but it can also be used directly in custom
/// formatter implementations.
class PrettyJsonSpan extends LeafSpan {
  /// Creates a span for [data].
  ///
  /// [config] controls the colors used while [indentLevel] tracks the nesting
  /// depth for recursive formatting.
  PrettyJsonSpan(
    this.data, {
    this.config = const DioChirpConfig(),
    this.indentLevel = 0,
  });

  /// The value to render.
  final Object? data;

  /// Visual configuration for keys and values.
  final DioChirpConfig config;

  /// The current indentation depth for nested values.
  final int indentLevel;

  /// Builds a formatted span representation of [data].
  ///
  /// Maps and lists are expanded recursively. Dio [FormData] and
  /// [MultipartFile] values receive specialized output for debugging uploads.
  @override
  LogSpan build() {
    final spacer = '  ' * indentLevel;

    /// FORM DATA
    if (data case final FormData formData) {
      return SpanSequence(
        children: [
          AnsiStyled(
            foreground: Ansi16.brightMagenta,
            italic: true,
            child: PlainText('FormData(\n'),
          ),

          /// FIELDS
          for (final field in formData.fields) ...[
            PlainText('$spacer  '),
            AnsiStyled(
              foreground: config.headerKeyColor,
              bold: true,
              child: PlainText(field.key),
            ),
            PlainText(': '),
            AnsiStyled(
              foreground: config.stringColor,
              child: PlainText('"${field.value}"'),
            ),
            NewLine(),
          ],

          /// FILES
          for (final file in formData.files) ...[
            PlainText('$spacer  '),
            AnsiStyled(
              foreground: config.headerKeyColor,
              bold: true,
              child: PlainText(file.key),
            ),
            PlainText(': '),
            _formatMultipartFile(file.value),
            NewLine(),
          ],
          PlainText('$spacer)'),
        ],
      );
    }

    /// MULTIPART FILE
    if (data case final MultipartFile mp) return _formatMultipartFile(mp);

    /// MAP
    if (data case final Map map) {
      if (map.isEmpty) return PlainText('{ }');

      final entries = map.entries.toList();

      return SpanSequence(
        children: [
          PlainText('{\n'),
          for (var i = 0; i < entries.length; i++) ...[
            PlainText('$spacer  '),
            AnsiStyled(
              foreground: config.headerKeyColor,
              bold: true,
              child: DataKey(entries[i].key),
            ),
            PlainText(': '),
            PrettyJsonSpan(
              entries[i].value,
              config: config,
              indentLevel: indentLevel + 1,
            ),
            if (i != entries.length - 1) PlainText(','),
            NewLine(),
          ],
          PlainText('$spacer}'),
        ],
      );
    }

    /// LIST
    if (data case List list) {
      if (list.isEmpty) return PlainText('[ ]');

      return SpanSequence(
        children: [
          PlainText('[\n'),
          for (var i = 0; i < list.length; i++) ...[
            PlainText('$spacer  '),
            PrettyJsonSpan(
              list[i],
              config: config,
              indentLevel: indentLevel + 1,
            ),
            if (i != list.length - 1) PlainText(','),
            NewLine(),
          ],

          PlainText('$spacer]'),
        ],
      );
    }

    /// NULL
    if (data == null) {
      return AnsiStyled(
        foreground: config.nullColor,
        italic: true,
        child: PlainText('NULL'),
      );
    }

    /// LEAF
    return AnsiStyled(foreground: _getValueColor(data), child: DataValue(data));
  }

  LogSpan _formatMultipartFile(MultipartFile file) {
    final sizeKb = (file.length / 1024).toStringAsFixed(2);

    return AnsiStyled(
      foreground: Ansi16.brightBlue,
      child: PlainText(
        'MultipartFile('
        'name: ${file.filename}, '
        'size: ${sizeKb}KB, '
        'type: ${file.contentType}'
        ')',
      ),
    );
  }

  ConsoleColor _getValueColor(Object? value) {
    if (value is String) return config.stringColor;
    if (value is num) return config.numberColor;
    if (value is bool) return config.boolColor;
    if (value == null) return config.nullColor;
    return Ansi16.brightWhite;
  }
}
