import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  static const route = '/help';

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<bool> _expanded = List<bool>.filled(3, false);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('helpCenter'))),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('needSupportTitle'), style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(strings.t('needSupportBody'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 24),
                  _HelpCard(
                    icon: IconlyLight.document,
                    title: strings.t('warmupTips'),
                    body: strings.t('warmupTipsBody'),
                  ),
                  const SizedBox(height: 16),
                  _HelpCard(
                    icon: IconlyLight.shield_done,
                    title: strings.t('injuryPrevention'),
                    body: strings.t('injuryPreventionBody'),
                  ),
                  const SizedBox(height: 24),
                  Text(strings.t('faq'), style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 4),
                expansionCallback: (index, isExpanded) {
                  setState(() => _expanded[index] = !isExpanded);
                },
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[0],
                    headerBuilder: (_, __) => ListTile(title: Text(strings.t('faqWarmup'))),
                    body: ListTile(title: Text(strings.t('faqWarmupBody'))),
                  ),
                  ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[1],
                    headerBuilder: (_, __) => ListTile(title: Text(strings.t('faqInjury'))),
                    body: ListTile(title: Text(strings.t('faqInjuryBody'))),
                  ),
                  ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[2],
                    headerBuilder: (_, __) => ListTile(title: Text(strings.t('faqContact'))),
                    body: ListTile(
                      title: Text(strings.t('faqContactBody')),
                      trailing: IconButton(
                        icon: const Icon(Icons.mail_outline),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('contactUs'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: theme.colorScheme.primary, child: const Icon(Icons.chat_bubble_outline)),
                    title: Text(strings.t('liveChat')),
                    subtitle: Text(strings.t('liveChatBody')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: theme.colorScheme.secondary, child: const Icon(Icons.forum_outlined)),
                    title: Text(strings.t('communityHelp')),
                    subtitle: Text(strings.t('communityHelpBody')),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
