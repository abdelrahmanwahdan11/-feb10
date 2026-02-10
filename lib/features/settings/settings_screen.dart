import 'package:flutter/material.dart';

import '../../core/app_config.dart';
import '../../core/app_localizations.dart';
import '../../core/session_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _store = SessionStore();
  bool _darkMode = true;
  bool _animations = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dark = await _store.getDarkMode();
    final ani = await _store.getAnimationsEnabled();
    if (!mounted) return;
    setState(() {
      _darkMode = dark;
      _animations = ani;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _darkMode,
            onChanged: (v) async {
              setState(() => _darkMode = v);
              await _store.setDarkMode(v);
            },
            title: Text(tr.t('darkMode')),
          ),
          SwitchListTile(
            value: _animations,
            onChanged: (v) async {
              setState(() => _animations = v);
              await _store.setAnimationsEnabled(v);
            },
            title: Text(tr.t('animationsEnabled')),
          ),
          ListTile(
            leading: const Icon(Icons.key_rounded),
            title: Text(tr.t('keysStatus')),
            subtitle: Text(
              '${tr.t('geminiStatus')}: ${AppConfig.hasGemini ? tr.t('statusReady') : tr.t('statusMissing')}\n${tr.t('searchStatus')}: ${AppConfig.hasSearch ? tr.t('statusReady') : tr.t('statusMissing')}',
            ),
          ),
        ],
      ),
    );
  }
}
