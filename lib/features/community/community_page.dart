import 'package:flutter/material.dart';

import '../../app/localization.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static const route = '/community';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).t('community'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Card(child: ListTile(title: Text('Daily challenge'), subtitle: Text('Complete 5k steps'))),
          Card(child: ListTile(title: Text('Weekly leaderboard'), subtitle: Text('Placeholder leaderboard'))),
          Card(child: ListTile(title: Text('Invite friend'), subtitle: Text('Share link placeholder'))),
        ],
      ),
    );
  }
}
