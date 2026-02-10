import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('integrations'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Google Drive')),
                SwitchListTile(value: false, onChanged: (_) {}, title: const Text('Notion')),
                SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Slack')),
                SwitchListTile(value: false, onChanged: (_) {}, title: const Text('Microsoft 365')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(tr.t('integrationsHint')),
        ],
      ),
    );
  }
}
