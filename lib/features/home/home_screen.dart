import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';
import '../../core/session_store.dart';
import '../ai/gemini_service.dart';
import '../loading/branded_loader.dart';
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
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'xlsm', 'csv'],
    );
    if (res != null && mounted) {
      setState(() => _fileName = res.files.single.name);
    }
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
User request: ${_promptCtrl.text}
File: ${_fileName ?? tr.t('noFileSelected')}
Please return actionable steps for Excel-compatible edits, analysis, and report generation.
''';

    final output = await _gemini.runPrompt(prompt, missingKeyMessage: tr.t('geminiMissing'));
    if (mounted) {
      setState(() {
        _result = output;
        _busy = false;
      });
    }
  }

  Future<void> _createDemoReport() async {
    final tr = AppLocalizations.of(context);
    setState(() => _busy = true);
    final path = await _excelService.createDemoReport();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = '${tr.t('demoCreated')}\n$path';
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
                            Expanded(
                              child: Text(tr.t('workspaceTitle'), style: Theme.of(context).textTheme.titleLarge),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${tr.t('welcomeBack')}: ${isGuest ? tr.t('modeGuest') : tr.t('modeUser')}'),
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
                              onPressed: _createDemoReport,
                              icon: const Icon(Icons.description_rounded),
                              label: Text(tr.t('createDemoReport')),
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
                FilledButton.icon(
                  onPressed: _runAiFlow,
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: Text(tr.t('generate')),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
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
