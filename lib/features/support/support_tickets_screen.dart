import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('supportTickets'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.support_agent_rounded), title: Text(tr.t('openTicket'))),
                ListTile(leading: const Icon(Icons.pending_actions_rounded), title: Text(tr.t('myTickets'))),
                ListTile(leading: const Icon(Icons.chat_bubble_outline_rounded), title: Text(tr.t('liveChat'))),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add), label: Text(tr.t('openTicket'))),
    );
  }
}
