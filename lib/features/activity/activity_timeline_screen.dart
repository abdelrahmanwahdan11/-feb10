import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class ActivityTimelineScreen extends StatelessWidget {
  const ActivityTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final activities = [
      tr.t('activityUpload'),
      tr.t('activityAiRun'),
      tr.t('activityReport'),
      tr.t('activityShare'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('activityTimeline'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.timeline_rounded),
            title: Text(activities[i]),
            subtitle: Text(tr.t('today')),
          ),
        ),
      ),
    );
  }
}
