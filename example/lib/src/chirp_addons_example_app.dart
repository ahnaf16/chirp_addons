import 'package:flutter/material.dart';

import 'example_controller.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7490),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
      ),
      home: ExampleHomePage(controller: _controller),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({required this.controller, super.key});

  final ExampleController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1080;
        final horizontalPadding = switch (constraints.maxWidth) {
          > 1280 => 32.0,
          > 720 => 24.0,
          _ => 16.0,
        };
        final topPadding = isWide ? 24.0 : 16.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('chirp_addons'),
            centerTitle: false,
            actions: [
              TextButton.icon(
                onPressed: controller.entries.isEmpty
                    ? null
                    : controller.clearLogs,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear logs'),
              ),
              SizedBox(width: horizontalPadding.clamp(8.0, 20.0)),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: isWide
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          24,
                        ),
                        child: _DesktopLayout(controller: controller),
                      )
                    : _MobileLayout(
                        controller: controller,
                        horizontalPadding: horizontalPadding,
                        topPadding: topPadding,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.controller});

  final ExampleController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: controller.examples.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final example = controller.examples[index];
                    return _ExampleCard(
                      example: example,
                      isBusy: controller.isBusy,
                      isRunning: controller.activeExampleId == example.id,
                      onRun: () => controller.runExample(example.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(flex: 10, child: _ConsolePanel(controller: controller)),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.controller,
    required this.horizontalPadding,
    required this.topPadding,
  });

  final ExampleController controller;
  final double horizontalPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            24,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              ..._buildExampleCards(),
              const SizedBox(height: 20),
              _ConsolePanel(controller: controller, minHeight: 300),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExampleCards() {
    return [
      for (var index = 0; index < controller.examples.length; index++) ...[
        _ExampleCard(
          example: controller.examples[index],
          isBusy: controller.isBusy,
          isRunning:
              controller.activeExampleId == controller.examples[index].id,
          onRun: () => controller.runExample(controller.examples[index].id),
        ),
        if (index != controller.examples.length - 1) const SizedBox(height: 14),
      ],
    ];
  }
}

class _ConsolePanel extends StatelessWidget {
  const _ConsolePanel({required this.controller, this.minHeight});

  final ExampleController controller;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final hasLogs = controller.entries.isNotEmpty;
    final logViewport = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xB30B1120),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: hasLogs
          ? SingleChildScrollView(
              child: SelectableText(
                controller.entries.join('\n\n'),
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  height: 1.5,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            )
          : Center(
              child: Text(
                'No logs yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: minHeight == null
            ? null
            : BoxConstraints(minHeight: minHeight!),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111827), Color(0xFF030712)],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live log output',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasLogs
                  ? 'Output is mirrored here from the same chirp writers used by the demos.'
                  : 'Run a demo to populate this console.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),
            if (minHeight == null)
              Expanded(child: logViewport)
            else
              SizedBox(height: minHeight! - 110, child: logViewport),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.example,
    required this.isBusy,
    required this.isRunning,
    required this.onRun,
  });

  final ExampleDefinition example;
  final bool isBusy;
  final bool isRunning;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompact) ...[
              Text(
                example.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                example.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onRun,
                  icon: isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(isRunning ? 'Running' : 'Run demo'),
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          example.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          example.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF475569),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: isBusy ? null : onRun,
                    icon: isRunning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(isRunning ? 'Running' : 'Run demo'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: example.highlights
                  .map(
                    (item) => Chip(
                      label: Text(item),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
