import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('billing'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(tr.t('currentPlan')),
              subtitle: Text(tr.t('proPlan')),
              trailing: FilledButton(onPressed: () {}, child: Text(tr.t('managePlan'))),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.receipt_long_outlined), title: Text(tr.t('invoiceHistory'))),
                ListTile(leading: const Icon(Icons.credit_card_outlined), title: Text(tr.t('paymentMethods'))),
                ListTile(leading: const Icon(Icons.discount_outlined), title: Text(tr.t('promoCodes'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
