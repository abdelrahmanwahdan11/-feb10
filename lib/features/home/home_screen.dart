import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_localizations.dart';
import '../ai/gemini_service.dart';
import '../loading/branded_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleLanguage});

  final VoidCallback onToggleLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptCtrl = TextEditingController();
  final _gemini = GeminiService();
  String? _fileName;
  String _result = '';
  bool _busy = false;

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
    if (res != null) {
      setState(() => _fileName = res.files.single.name);
    }
  }

  Future<void> _runAiFlow() async {
    if (_promptCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);

    final prompt = '''
User request: ${_promptCtrl.text}
File: ${_fileName ?? 'No file selected'}
Please return actionable steps for Excel-compatible edits, analysis, and report generation.
''';

    final output = await _gemini.runPrompt(prompt);
    if (mounted) {
      setState(() {
        _result = output;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.t('home')),
        actions: [
          IconButton(onPressed: widget.onToggleLanguage, icon: const Icon(Icons.language_rounded)),
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
                              child: Text('Excel + AI Workspace', style: Theme.of(context).textTheme.titleLarge),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(_fileName ?? 'No file selected'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _pickExcelFile,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: Text(tr.t('upload')),
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
                      _result.isEmpty ? 'AI output will appear here...' : _result,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ].animate(interval: 80.ms).fadeIn().slideY(begin: 0.08),
            ),
    );
  }
}
