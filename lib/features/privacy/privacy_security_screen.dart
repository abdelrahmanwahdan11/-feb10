import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('privacySecurity'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.lock_outline), title: Text(tr.t('secureMode'))),
                ListTile(leading: const Icon(Icons.shield_outlined), title: Text(tr.t('twoFactorAuth'))),
                ListTile(leading: const Icon(Icons.gpp_good_outlined), title: Text(tr.t('dataEncryption'))),
                ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: Text(tr.t('privacyControls'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
