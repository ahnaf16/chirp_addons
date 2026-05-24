import 'package:chirp_addons_example/src/example_controller.dart';
import 'package:flutter/material.dart';

import 'src/chirp_addons_example_app.dart';

void main() {
  runApp(const ChirpAddonsExampleApp());
}

class ChirpAddonsExampleApp extends StatefulWidget {
  const ChirpAddonsExampleApp({super.key});

  @override
  State<ChirpAddonsExampleApp> createState() => _ChirpAddonsExampleAppState();
}

class _ChirpAddonsExampleAppState extends State<ChirpAddonsExampleApp> {
  late final ExampleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExampleController()..addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'chirp_addons Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, color: Colors.white),
      ),
      home: ExampleHomePage(controller: _controller),
    );
  }
}
