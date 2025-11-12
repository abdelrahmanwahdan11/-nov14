import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const route = '/profile';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(strings.t('profile')),
              subtitle: const Text('Athlete'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(strings.t('settings')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text('Badges'),
              subtitle: const Text('Coming soon'),
              leading: const Icon(IconlyLight.star),
            ),
          ),
        ],
      ),
    );
  }
}
