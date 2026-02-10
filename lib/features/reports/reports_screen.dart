import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../home/excel_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _excelService = ExcelService();
  bool _loading = false;

  Future<void> _generateMonthlyReport() async {
    final tr = AppLocalizations.of(context);
    setState(() => _loading = true);
    final path = await _excelService.createDemoReport();
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr.t('savedTo')}: $path')));
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('reportsCenter'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bar_chart_rounded),
                    title: Text(tr.t('monthlySalesReport')),
                    subtitle: Text(tr.t('generateMonthlyReportDesc')),
                    trailing: FilledButton(
                      onPressed: _generateMonthlyReport,
                      child: Text(tr.t('generate')),
                    ),
                  ),
                ),
                Card(child: ListTile(leading: const Icon(Icons.pie_chart_rounded), title: Text(tr.t('expenseBreakdownReport')))),
                Card(child: ListTile(leading: const Icon(Icons.insights_rounded), title: Text(tr.t('forecastReport')))),
              ],
            ),
    );
  }
}
