import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final items = [
      tr.t('notifInsightReady'),
      tr.t('notifReportGenerated'),
      tr.t('notifSyncComplete'),
      tr.t('notifAiSuggestion'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(tr.t('notifications'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(items[index]),
            subtitle: Text(tr.t('today')),
          ),
        ),
      ),
    );
  }
}
