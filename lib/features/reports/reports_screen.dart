import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('reportsCenter'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const Icon(Icons.bar_chart_rounded), title: Text(tr.t('monthlySalesReport')))),
          Card(child: ListTile(leading: const Icon(Icons.pie_chart_rounded), title: Text(tr.t('expenseBreakdownReport')))),
          Card(child: ListTile(leading: const Icon(Icons.insights_rounded), title: Text(tr.t('forecastReport')))),
        ],
      ),
    );
  }
}
