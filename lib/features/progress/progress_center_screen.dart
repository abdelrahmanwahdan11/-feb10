import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../core/session_store.dart';

class ProgressCenterScreen extends StatefulWidget {
  const ProgressCenterScreen({super.key});

  @override
  State<ProgressCenterScreen> createState() => _ProgressCenterScreenState();
}

class _ProgressCenterScreenState extends State<ProgressCenterScreen> {
  final _store = SessionStore();

  int _uploads = 0;
  int _aiRuns = 0;
  int _webRuns = 0;
  int _autopilotRuns = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uploads = await _store.getIntPref('progress_uploads');
    final ai = await _store.getIntPref('progress_ai_runs');
    final web = await _store.getIntPref('progress_web_runs');
    final auto = await _store.getIntPref('progress_autopilot_runs');
    if (!mounted) return;
    setState(() {
      _uploads = uploads;
      _aiRuns = ai;
      _webRuns = web;
      _autopilotRuns = auto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    Widget kpi(String label, int value, IconData icon) => Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('progressCenter'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          kpi(tr.t('uploadedFilesCount'), _uploads, Icons.upload_file_rounded),
          kpi(tr.t('aiRunsCount'), _aiRuns, Icons.auto_awesome_rounded),
          kpi(tr.t('webSearchRunsCount'), _webRuns, Icons.travel_explore_rounded),
          kpi(tr.t('autopilotRunsCount'), _autopilotRuns, Icons.smart_toy_outlined),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tr.t('progressInsights'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
