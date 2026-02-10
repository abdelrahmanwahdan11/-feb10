import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class DataCatalogScreen extends StatelessWidget {
  const DataCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final datasets = ['Sales_Q1', 'Customers_Master', 'Ops_KPIs', 'Forecast_2026'];
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('dataCatalog'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: datasets.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: Text(datasets[i]),
            subtitle: Text(tr.t('lastUpdatedToday')),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        ),
      ),
    );
  }
}
