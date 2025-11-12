import 'package:flutter/material.dart';

import '../../app/localization.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  static const route = '/activity';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('activity'))),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Session ${index + 1}'),
            subtitle: const Text('5.2 km · 32 min'),
          );
        },
      ),
    );
  }
}
