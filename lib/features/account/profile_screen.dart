import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, child: Text(tr.t('name').substring(0, 1))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.t('welcomeBack'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(tr.t('modeUser')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.badge_outlined), title: Text(tr.t('name'))),
                ListTile(leading: const Icon(Icons.email_outlined), title: Text(tr.t('email'))),
                ListTile(leading: const Icon(Icons.language_outlined), title: Text(tr.t('appLanguage'))),
                ListTile(leading: const Icon(Icons.workspace_premium_outlined), title: Text(tr.t('subscriptionStatus'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
