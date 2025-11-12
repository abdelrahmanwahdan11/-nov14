import 'package:flutter/material.dart';

import '../../app/localization.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  static const route = '/plans';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('plans'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (final level in ['Beginner', 'Intermediate', 'Advanced'])
            Card(
              child: ListTile(
                title: Text(level),
                subtitle: const Text('Adaptive placeholder'),
              ),
            ),
        ],
      ),
    );
  }
}
