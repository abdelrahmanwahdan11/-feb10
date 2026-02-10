import 'package:flutter/material.dart';

import '../../core/app_config.dart';
import '../../core/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(value: true, onChanged: (_) {}, title: Text(tr.t('darkMode'))),
          SwitchListTile(value: true, onChanged: (_) {}, title: Text(tr.t('animationsEnabled'))),
          ListTile(
            leading: const Icon(Icons.key_rounded),
            title: Text(tr.t('keysStatus')),
            subtitle: Text('${tr.t('geminiStatus')}: ${AppConfig.hasGemini ? tr.t('statusReady') : tr.t('statusMissing')}\n${tr.t('searchStatus')}: ${AppConfig.hasSearch ? tr.t('statusReady') : tr.t('statusMissing')}'),
          ),
        ],
      ),
    );
  }
}
