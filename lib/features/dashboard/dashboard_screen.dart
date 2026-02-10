import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    Widget metric(String label, String value, IconData icon) => Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('dashboard'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          metric(tr.t('kpiRevenue'), '+18.4%', Icons.trending_up_rounded),
          metric(tr.t('kpiEfficiency'), '92%', Icons.speed_rounded),
          metric(tr.t('kpiReports'), '47', Icons.summarize_outlined),
          metric(tr.t('kpiAutomation'), '31', Icons.auto_mode_rounded),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(tr.t('dashboardInsight')),
            ),
          ),
        ],
      ),
    );
  }
}
