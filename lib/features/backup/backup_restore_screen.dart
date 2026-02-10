import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('backupRestore'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.backup_outlined), title: Text(tr.t('createBackup'))),
                ListTile(leading: const Icon(Icons.restore_page_outlined), title: Text(tr.t('restoreBackup'))),
                ListTile(leading: const Icon(Icons.history_rounded), title: Text(tr.t('backupHistory'))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(tr.t('backupHint')),
        ],
      ),
    );
  }
}
