import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class ExpertReviewScreen extends StatelessWidget {
  const ExpertReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final checks = [
      tr.t('reviewArchitecture'),
      tr.t('reviewLocalization'),
      tr.t('reviewExcelFlow'),
      tr.t('reviewAiFlow'),
      tr.t('reviewErrorHandling'),
      tr.t('reviewSecurity'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('expertReview'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(tr.t('expertReviewIntro'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...checks.map(
            (c) => Card(
              child: ListTile(
                leading: const Icon(Icons.verified_rounded, color: Colors.green),
                title: Text(c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
