import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  }

  Future<void> _loadAuthMode() async {
    final mode = await _store.getAuthMode();
    if (mounted) setState(() => _authMode = mode);
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    final tr = AppLocalizations.of(context);
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'xlsm', 'csv'],
    );
    if (res == null || !mounted) return;

    final file = res.files.single;
    final preview = await _excelService.previewFile(file);

    setState(() {
      _fileName = file.name;
      _result = '${tr.t('filePreview')}:\n$preview';
    });
  }

  Future<void> _runAiFlow() async {
    final tr = AppLocalizations.of(context);
    if ((_authMode ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('authRequired'))));
      return;
    }
    if (_promptCtrl.text.trim().isEmpty) return;

    setState(() => _busy = true);

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

    final output = await _gemini.runPrompt(prompt, missingKeyMessage: tr.t('geminiMissing'));
    if (!mounted) return;

    setState(() {
      _result = output;
      _busy = false;
    });
  }

  Future<void> _runWebInsights() async {
    final tr = AppLocalizations.of(context);
    final query = _promptCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _busy = true);

    if (!_search.isConfigured) {
      setState(() {
        _result = tr.t('searchMissing');
        _busy = false;
      });
      return;
    }

    final links = await _search.search(query);
    if (!mounted) return;

    setState(() {
      _result = links.isEmpty ? tr.t('searchNoResult') : '${tr.t('searchResults')}\n${links.join('\n')}';
      _busy = false;
    });
  }

  Future<void> _runAutopilot() async {
    final tr = AppLocalizations.of(context);
    setState(() => _busy = true);

    final aiPlan = await _gemini.runPrompt(
      'Create an autonomous Excel workflow plan for: ${_promptCtrl.text}',
      missingKeyMessage: tr.t('geminiMissing'),
    );
    final reportPath = await _excelService.createDemoReport();

    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = '${tr.t('autopilotDone')}\n\n$aiPlan\n\n${tr.t('generatedFilePath')}:\n$reportPath';
    });
  }

  Future<void> _signOut() async {
    await _store.signOut();
    if (!mounted) return;
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
