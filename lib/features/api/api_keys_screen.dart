import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class ApiKeysScreen extends StatelessWidget {
  const ApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('apiKeysManager'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.vpn_key_outlined), title: Text('Gemini API Key'), trailing: Text(tr.t('statusReady'))),
                ListTile(leading: const Icon(Icons.vpn_key_outlined), title: Text('Search API Key'), trailing: Text(tr.t('statusMissing'))),
                ListTile(leading: const Icon(Icons.engineering_outlined), title: Text(tr.t('rotateKeys')), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
