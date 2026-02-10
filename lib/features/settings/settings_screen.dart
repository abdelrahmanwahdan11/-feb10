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

  final _boolPrefs = <String, bool>{
    'pref_haptics': true,
    'pref_compact': false,
    'pref_autosave': true,
    'pref_cloudSync': true,
    'pref_notifications': true,
    'pref_formulaHints': true,
    'pref_aiAutofill': false,
    'pref_highAccuracy': false,
    'pref_batterySaver': false,
    'pref_offlineCache': true,
    'pref_secureMode': true,
    'pref_experimental': false,
  };

  String _languageCode = 'ar';
  String _exportDefault = 'xlsx';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dark = await _store.getDarkMode();
    final ani = await _store.getAnimationsEnabled();
    final lang = await _store.getStringPref('pref_language') ?? 'ar';
    final exportType = await _store.getStringPref('pref_export_default') ?? 'xlsx';

    final loaded = <String, bool>{};
    for (final entry in _boolPrefs.entries) {
      loaded[entry.key] = await _store.getBoolPref(entry.key, defaultValue: entry.value);
    }

    if (!mounted) return;
    setState(() {
      _darkMode = dark;
      _animations = ani;
      _languageCode = lang;
      _exportDefault = exportType;
      _boolPrefs
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _togglePref(String key, bool value) async {
    setState(() => _boolPrefs[key] = value);
    await _store.setBoolPref(key, value);
  }

  Future<void> _setLanguage(String value) async {
    setState(() => _languageCode = value);
    await _store.setStringPref('pref_language', value);
  }

  Future<void> _setExportDefault(String value) async {
    setState(() => _exportDefault = value);
    await _store.setStringPref('pref_export_default', value);
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionTitle(tr.t('appearanceSection')),
          Card(
            child: Column(
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
                SwitchListTile(
                  value: _boolPrefs['pref_compact']!,
                  onChanged: (v) => _togglePref('pref_compact', v),
                  title: Text(tr.t('compactMode')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_haptics']!,
                  onChanged: (v) => _togglePref('pref_haptics', v),
                  title: Text(tr.t('haptics')),
                ),
              ],
            ),
          ),

          _sectionTitle(tr.t('workflowSection')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _boolPrefs['pref_autosave']!,
                  onChanged: (v) => _togglePref('pref_autosave', v),
                  title: Text(tr.t('autoSave')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_cloudSync']!,
                  onChanged: (v) => _togglePref('pref_cloudSync', v),
                  title: Text(tr.t('cloudSync')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_offlineCache']!,
                  onChanged: (v) => _togglePref('pref_offlineCache', v),
                  title: Text(tr.t('offlineCache')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_notifications']!,
                  onChanged: (v) => _togglePref('pref_notifications', v),
                  title: Text(tr.t('smartNotifications')),
                ),
                ListTile(
                  title: Text(tr.t('defaultExportFormat')),
                  subtitle: Text(_exportDefault.toUpperCase()),
                  trailing: DropdownButton<String>(
                    value: _exportDefault,
                    items: const [
                      DropdownMenuItem(value: 'xlsx', child: Text('XLSX')),
                      DropdownMenuItem(value: 'csv', child: Text('CSV')),
                      DropdownMenuItem(value: 'json', child: Text('JSON')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      _setExportDefault(v);
                    },
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle(tr.t('aiSection')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _boolPrefs['pref_formulaHints']!,
                  onChanged: (v) => _togglePref('pref_formulaHints', v),
                  title: Text(tr.t('formulaHints')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_aiAutofill']!,
                  onChanged: (v) => _togglePref('pref_aiAutofill', v),
                  title: Text(tr.t('aiAutofill')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_highAccuracy']!,
                  onChanged: (v) => _togglePref('pref_highAccuracy', v),
                  title: Text(tr.t('highAccuracyMode')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_experimental']!,
                  onChanged: (v) => _togglePref('pref_experimental', v),
                  title: Text(tr.t('experimentalFeatures')),
                ),
              ],
            ),
          ),

          _sectionTitle(tr.t('securitySection')),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _boolPrefs['pref_secureMode']!,
                  onChanged: (v) => _togglePref('pref_secureMode', v),
                  title: Text(tr.t('secureMode')),
                ),
                SwitchListTile(
                  value: _boolPrefs['pref_batterySaver']!,
                  onChanged: (v) => _togglePref('pref_batterySaver', v),
                  title: Text(tr.t('batterySaver')),
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
          ),

          _sectionTitle(tr.t('languageSection')),
          Card(
            child: ListTile(
              title: Text(tr.t('appLanguage')),
              subtitle: Text(_languageCode == 'ar' ? 'العربية' : 'English'),
              trailing: DropdownButton<String>(
                value: _languageCode,
                items: const [
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  _setLanguage(v);
                },
              ),
            ),
          ),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await _store.resetPreferences();
              if (!mounted) return;
              await _load();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('settingsResetDone'))));
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(tr.t('resetSettings')),
          ),
        ],
      ),
    );
  }
}
