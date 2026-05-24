import 'dart:developer';

import 'package:chirp/chirp.dart';
import 'package:chirp_addons/chirp_addons.dart';

void main() {
  final logger = ChirpLogger(name: 'JSON')
    ..addConsoleWriter(
      output: log,
      formatter: ChirpPrettyJsonFormatter(getCallerInfo: true),
    );

  logger.success(
    'Fetched profile payload',
    data: {
      'user': {'id': 7, 'name': 'Taylor', 'emailVerified': true},
      'permissions': ['read', 'write'],
      'metadata': {'source': 'cache', 'latencyMs': 12},
    },
  );
}
