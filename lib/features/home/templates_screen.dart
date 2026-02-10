import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import 'excel_service.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _excelService = ExcelService();
  bool _busy = false;

  Future<void> _buildBudgetTemplate() async {
    final tr = AppLocalizations.of(context);
    setState(() => _busy = true);
    final path = await _excelService.createBudgetTemplate();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr.t('savedTo')}: $path')));
  }

  Future<void> _buildInvoiceTemplate() async {
    final tr = AppLocalizations.of(context);
    setState(() => _busy = true);
    final path = await _excelService.createInvoiceTemplate();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr.t('savedTo')}: $path')));
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('templatesCenter'))),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_rounded),
                    title: Text(tr.t('budgetTemplate')),
                    subtitle: Text(tr.t('budgetTemplateDesc')),
                    trailing: FilledButton(
                      onPressed: _buildBudgetTemplate,
                      child: Text(tr.t('generate')),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_rounded),
                    title: Text(tr.t('invoiceTemplate')),
                    subtitle: Text(tr.t('invoiceTemplateDesc')),
                    trailing: FilledButton(
                      onPressed: _buildInvoiceTemplate,
                      child: Text(tr.t('generate')),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
