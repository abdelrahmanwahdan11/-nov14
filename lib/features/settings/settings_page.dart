import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../app/theme.dart';
import '../help/help_page.dart';
import '../paywall/paywall_page.dart';
import '../shared/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const route = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    final controller = state.themeController;
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: Text(strings.t('darkMode')),
            value: controller.isDark,
            onChanged: (value) {
              controller.toggleDark(value);
              state.persistTheme();
            },
          ),
          ListTile(
            title: Text(strings.t('choosePrimaryColor')),
            subtitle: Text('#${controller.primarySeed.value.toRadixString(16)}'),
            trailing: CircleAvatar(backgroundColor: controller.primarySeed),
            onTap: () async {
              final selected = await showDialog<Color>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(strings.t('choosePrimaryColor')),
                  content: Wrap(
                    spacing: 12,
                    children: [
                      for (final color in [
                        const Color(0xFF4C6EF5),
                        const Color(0xFF22C55E),
                        const Color(0xFFF97316),
                        const Color(0xFF0EA5E9),
                        const Color(0xFF8B5CF6),
                      ])
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(color),
                          child: CircleAvatar(backgroundColor: color, radius: 20),
                        )
                    ],
                  ),
                ),
              );
              if (selected != null) {
                controller.updateSeed(selected);
                state.persistTheme();
              }
            },
          ),
          ListTile(
            title: Text(strings.t('language')),
            subtitle: Text(state.locale.languageCode),
            onTap: () async {
              final selected = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('العربية'),
                      onTap: () => Navigator.pop(context, 'ar'),
                    ),
                    ListTile(
                      title: const Text('English'),
                      onTap: () => Navigator.pop(context, 'en'),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                setState(() => state.updateLocale(Locale(selected)));
              }
            },
          ),
          const Divider(),
          ListTile(title: Text(strings.t('units')), subtitle: Text(strings.t('metric'))),
          SwitchListTile(title: Text(strings.t('notifications')), value: true, onChanged: (_) {}),
          ListTile(title: Text(strings.t('privacy'))),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded),
            title: Text(strings.t('fitProPlus')),
            subtitle: Text(strings.t('unlockProSubtitle')),
            onTap: () => Navigator.pushNamed(context, PaywallPage.route),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(strings.t('helpCenter')),
            subtitle: Text(strings.t('needSupportBody')),
            onTap: () => Navigator.pushNamed(context, HelpPage.route),
          ),
        ],
      ),
    );
  }
}
