import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('helpCenter'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const Icon(Icons.help_outline_rounded), title: Text(tr.t('faqSheetEdit')))),
          Card(child: ListTile(leading: const Icon(Icons.help_outline_rounded), title: Text(tr.t('faqFormulas')))),
          Card(child: ListTile(leading: const Icon(Icons.help_outline_rounded), title: Text(tr.t('faqExport')))),
        ],
      ),
    );
  }
}
