import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final items = [
      (Icons.analytics_rounded, tr.t('onboarding1')),
      (Icons.insert_chart_rounded, tr.t('onboarding2')),
      (Icons.table_chart_rounded, tr.t('onboarding3')),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$1, size: 120, color: Theme.of(context).colorScheme.primary)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: -8, end: 8, duration: 1500.ms),
                      const SizedBox(height: 24),
                      Text(item.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _index == i ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_index == items.length - 1) {
                  context.go('/auth');
                } else {
                  _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                }
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              label: Text(_index == items.length - 1 ? tr.t('start') : tr.t('next')),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
