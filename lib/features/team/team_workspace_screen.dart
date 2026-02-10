import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';

class TeamWorkspaceScreen extends StatelessWidget {
  const TeamWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final members = ['A. Analyst', 'M. Manager', 'D. Data Engineer'];
    return Scaffold(
      appBar: AppBar(title: Text(tr.t('teamWorkspace'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(members[i]),
            subtitle: Text(tr.t('activeNow')),
            trailing: const Icon(Icons.more_horiz),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, label: Text(tr.t('inviteMember')), icon: const Icon(Icons.person_add_alt_1_rounded)),
    );
  }
}
