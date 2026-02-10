import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class AutomationCenterScreen extends StatelessWidget {
  const AutomationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('automationCenter'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(value: true, onChanged: (_) {}, title: Text(tr.t('autoCleanup'))),
                SwitchListTile(value: true, onChanged: (_) {}, title: Text(tr.t('autoForecast'))),
                SwitchListTile(value: false, onChanged: (_) {}, title: Text(tr.t('autoDistribution'))),
                SwitchListTile(value: true, onChanged: (_) {}, title: Text(tr.t('scheduledReports'))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow_rounded), label: Text(tr.t('runAllAutomations'))),
        ],
      ),
    );
  }
}
