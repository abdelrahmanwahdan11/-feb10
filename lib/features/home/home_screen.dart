import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/app_localizations.dart';
import '../../core/session_store.dart';
import '../ai/gemini_service.dart';
import '../loading/branded_loader.dart';
import '../search/web_search_service.dart';
import 'excel_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleLanguage});

  final VoidCallback onToggleLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptCtrl = TextEditingController();
  final _gemini = GeminiService();
  final _excelService = ExcelService();
  final _store = SessionStore();
  final _search = WebSearchService(
    apiKey: AppConfig.searchApiKey,
    cx: AppConfig.searchEngineCx,
  );

  String? _fileName;
  String _result = '';
  bool _busy = false;
  String? _authMode;

  @override
  void initState() {
    super.initState();
    _loadAuthMode();
    _loadPromptDraft();
    _promptCtrl.addListener(_persistPromptDraft);
  }

  Future<void> _loadAuthMode() async {
    final mode = await _store.getAuthMode();
    if (mounted) setState(() => _authMode = mode);
  }


  Future<void> _loadPromptDraft() async {
    final draft = await _store.getPromptDraft();
    if (draft == null || !mounted) return;
    _promptCtrl.text = draft;
  }

  Future<void> _persistPromptDraft() async {
    await _store.setPromptDraft(_promptCtrl.text);
  }

  Future<void> _openRoute(String route) async {
    await _store.setLastVisitedRoute(route);
    if (!mounted) return;
    context.push(route);
  }

  @override
  void dispose() {
    _promptCtrl.removeListener(_persistPromptDraft);
    _promptCtrl.dispose();
    _search.dispose();
    super.dispose();
  }

  void _setResult(String text) {
    if (!mounted) return;
    setState(() => _result = text);
  }

  bool _ensureAuthorized() {
    final tr = AppLocalizations.of(context);
    if ((_authMode ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('authRequired'))));
      return false;
    }
    return true;
  }

  Future<void> _pickExcelFile() async {
    final tr = AppLocalizations.of(context);
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'xlsm', 'csv'],
      );
      if (res == null || !mounted) return;

      final file = res.files.single;
      final preview = await _excelService.previewFile(file);
      final previewText = switch (preview.status) {
        PreviewStatus.pathMissing => tr.t('previewPathMissing'),
        PreviewStatus.csvEmpty => tr.t('previewCsvEmpty'),
        PreviewStatus.spreadsheetSelected => tr.t('previewSpreadsheetSelected'),
        PreviewStatus.unsupported => tr.t('previewUnsupported'),
        PreviewStatus.previewData => preview.content,
      };

      setState(() {
        _fileName = file.name;
        _result = '${tr.t('filePreview')}:\n$previewText';
      });
      await _store.incrementIntPref('progress_uploads');
    } catch (_) {
      _setResult(tr.t('unexpectedError'));
    }
  }

  Future<void> _runAiFlow() async {
    final tr = AppLocalizations.of(context);
    if (!_ensureAuthorized()) return;
    if (_promptCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('emptyPrompt'))));
      return;
    }

    setState(() => _busy = true);
    try {
      final prompt = '''
You are an Excel automation assistant.
User request: ${_promptCtrl.text}
File: ${_fileName ?? tr.t('noFileSelected')}
Please return:
1) Data cleaning plan
2) Formula suggestions
3) Visualization recommendations
4) Final report structure
''';

      final output = await _gemini.runPrompt(
        prompt,
        missingKeyMessage: tr.t('geminiMissing'),
        fallbackErrorMessage: tr.t('aiFailed'),
      );
      _setResult(output);
      await _store.incrementIntPref('progress_ai_runs');
    } catch (_) {
      _setResult(tr.t('unexpectedError'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runWebInsights() async {
    final tr = AppLocalizations.of(context);
    if (!_ensureAuthorized()) return;
    final query = _promptCtrl.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('emptyPrompt'))));
      return;
    }

    setState(() => _busy = true);

    try {
      if (!_search.isConfigured) {
        _setResult(tr.t('searchMissing'));
        return;
      }

      final links = await _search.search(query);
      _setResult(links.isEmpty ? tr.t('searchNoResult') : '${tr.t('searchResults')}\n${links.join('\n')}');
      await _store.incrementIntPref('progress_web_runs');
    } catch (_) {
      _setResult(tr.t('unexpectedError'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runAutopilot() async {
    final tr = AppLocalizations.of(context);
    if (!_ensureAuthorized()) return;
    if (_promptCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('emptyPrompt'))));
      return;
    }

    setState(() => _busy = true);
    try {
      final aiPlan = await _gemini.runPrompt(
        'Create an autonomous Excel workflow plan for: ${_promptCtrl.text}',
        missingKeyMessage: tr.t('geminiMissing'),
        fallbackErrorMessage: tr.t('aiFailed'),
      );
      final reportPath = await _excelService.createDemoReport();
      _setResult('${tr.t('autopilotDone')}\n\n$aiPlan\n\n${tr.t('generatedFilePath')}:\n$reportPath');
      await _store.incrementIntPref('progress_autopilot_runs');
    } catch (_) {
      _setResult(tr.t('unexpectedError'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyOutput() async {
    final tr = AppLocalizations.of(context);
    if (_result.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _result));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('copied'))));
  }

  Future<void> _signOut() async {
    await _store.signOut();
    if (!mounted) return;
    _setResult('');
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isGuest = _authMode == 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.t('home')),
        actions: [
          IconButton(onPressed: widget.onToggleLanguage, icon: const Icon(Icons.language_rounded)),
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout_rounded), tooltip: tr.t('signOut')),
        ],
      ),
      body: _busy
          ? BrandedLoader(label: tr.t('analyze'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.table_chart_rounded, size: 34).animate(onPlay: (c) => c.repeat()).shimmer(),
                            const SizedBox(width: 10),
                            Expanded(child: Text(tr.t('workspaceTitle'), style: Theme.of(context).textTheme.titleLarge)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${tr.t('welcomeBack')}: ${isGuest ? tr.t('modeGuest') : tr.t('modeUser')}'),
                        const SizedBox(height: 8),
                        Text('${tr.t('geminiStatus')}: ${AppConfig.hasGemini ? tr.t('statusReady') : tr.t('statusMissing')}'),
                        Text('${tr.t('searchStatus')}: ${AppConfig.hasSearch ? tr.t('statusReady') : tr.t('statusMissing')}'),
                        const SizedBox(height: 14),
                        Text(_fileName ?? tr.t('noFileSelected')),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              onPressed: _pickExcelFile,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(tr.t('upload')),
                            ),
                            OutlinedButton.icon(
                              onPressed: _runAutopilot,
                              icon: const Icon(Icons.auto_mode_rounded),
                              label: Text(tr.t('autopilot')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/sheet'),
                              icon: const Icon(Icons.table_view_rounded),
                              label: Text(tr.t('openSheetEditor')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/reports'),
                              icon: const Icon(Icons.assessment_rounded),
                              label: Text(tr.t('reportsCenter')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/settings'),
                              icon: const Icon(Icons.settings_rounded),
                              label: Text(tr.t('settings')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/progress'),
                              icon: const Icon(Icons.insights_rounded),
                              label: Text(tr.t('progressCenter')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/profile'),
                              icon: const Icon(Icons.person_outline_rounded),
                              label: Text(tr.t('profile')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/notifications'),
                              icon: const Icon(Icons.notifications_none_rounded),
                              label: Text(tr.t('notifications')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/privacy'),
                              icon: const Icon(Icons.shield_outlined),
                              label: Text(tr.t('privacySecurity')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/billing'),
                              icon: const Icon(Icons.payments_outlined),
                              label: Text(tr.t('billing')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/team'),
                              icon: const Icon(Icons.groups_outlined),
                              label: Text(tr.t('teamWorkspace')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/integrations'),
                              icon: const Icon(Icons.extension_outlined),
                              label: Text(tr.t('integrations')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/activity'),
                              icon: const Icon(Icons.timeline_outlined),
                              label: Text(tr.t('activityTimeline')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/backup'),
                              icon: const Icon(Icons.backup_outlined),
                              label: Text(tr.t('backupRestore')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/support-tickets'),
                              icon: const Icon(Icons.support_agent_outlined),
                              label: Text(tr.t('supportTickets')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/dashboard'),
                              icon: const Icon(Icons.space_dashboard_outlined),
                              label: Text(tr.t('dashboard')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/automation'),
                              icon: const Icon(Icons.auto_mode_outlined),
                              label: Text(tr.t('automationCenter')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/data-catalog'),
                              icon: const Icon(Icons.dataset_outlined),
                              label: Text(tr.t('dataCatalog')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/api-keys'),
                              icon: const Icon(Icons.vpn_key_outlined),
                              label: Text(tr.t('apiKeysManager')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/expert-review'),
                              icon: const Icon(Icons.fact_check_rounded),
                              label: Text(tr.t('expertReview')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/templates'),
                              icon: const Icon(Icons.inventory_2_rounded),
                              label: Text(tr.t('templatesCenter')),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openRoute('/help-center'),
                              icon: const Icon(Icons.support_agent_rounded),
                              label: Text(tr.t('helpCenter')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _promptCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: tr.t('aiPrompt'),
                    hintText: tr.t('searchHint'),
                    prefixIcon: const Icon(Icons.auto_awesome),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _runAiFlow,
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: Text(tr.t('generate')),
                    ),
                    OutlinedButton.icon(
                      onPressed: _runWebInsights,
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: Text(tr.t('searchWeb')),
                    ),
                    TextButton.icon(
                      onPressed: _copyOutput,
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(tr.t('copyOutput')),
                    ),
                    TextButton.icon(
                      onPressed: () => _setResult(''),
                      icon: const Icon(Icons.clear_all_rounded),
                      label: Text(tr.t('clearOutput')),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: SelectableText(
                      _result.isEmpty ? tr.t('aiOutputPlaceholder') : _result,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ].animate(interval: 80.ms).fadeIn().slideY(begin: 0.08),
            ),
    );
  }
}
