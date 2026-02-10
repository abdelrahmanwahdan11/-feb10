import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('notFoundTitle'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 72),
              const SizedBox(height: 12),
              Text(tr.t('notFoundTitle'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(tr.t('notFoundMessage'), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_outlined),
                label: Text(tr.t('backToHome')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
