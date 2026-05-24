import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';

void main() {
  final logger = ChirpLogger(name: 'BASIC')
    ..addConsoleWriter(
      output: log,
      formatter: ChirpPrettyJsonFormatter(getCallerInfo: false),
    );

  logger.info(
    'Application started',
    data: {
      'environment': 'development',
      'features': ['dio-logging', 'pretty-json'],
      'debug': true,
    },
  );
}
