import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  static const route = '/pro';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final perks = [
      strings.t('perkPersonalized'),
      strings.t('perkDynamicPlans'),
      strings.t('perkLiveSessions'),
      strings.t('perkAdvancedMetrics'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.t('fitProPlus'))),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('proHeadline'), style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(strings.t('proSubtitle'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 24),
                  OpenContainer(
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    openColor: theme.colorScheme.surface,
                    closedColor: theme.colorScheme.surface,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedBuilder: (context, open) {
                      return Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 24,
                              right: 24,
                              child: Chip(
                                label: Text(
                                  strings.t('bestValue'),
                                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                                ),
                                backgroundColor: theme.colorScheme.onPrimary.withOpacity(.9),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.t('unlockPro'),
                                    style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary),
                                  ),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: open,
                                    child: Text(strings.t('viewPlans')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    openBuilder: (context, close) {
                      return Scaffold(
                        appBar: AppBar(title: Text(strings.t('viewPlans'))),
                        body: ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final isPopular = index == 1;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: theme.colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(['Starter', 'Pro', 'Elite'][index], style: theme.textTheme.titleLarge),
                                      const Spacer(),
                                      if (isPopular)
                                        Chip(
                                          label: Text(strings.t('popular')),
                                          backgroundColor: theme.colorScheme.primaryContainer,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(['\\$6.99', '\\$12.99', '\\$19.99'][index], style: theme.textTheme.headlineSmall),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      for (final perk in perks.take(index == 0 ? 2 : index == 1 ? 3 : perks.length))
                                        Chip(
                                          avatar: const Icon(Icons.check_circle_outline),
                                          label: Text(perk),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: () {},
                                    child: Text(strings.t('startTrial')),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(strings.t('proIncludes'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...perks.map(
                    (perk) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.star_outline_rounded),
                      title: Text(perk),
                      subtitle: Text(strings.t('perkSubtitle')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(strings.t('testimonials'), style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(.1),
                    child: Icon(
                      index.isEven ? IconlyBold.heart : IconlyBold.graph,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(['Aisha', 'James', 'Noor', 'Carlos'][index % 4]),
                  subtitle: Text(strings.t('testimonialBody')),
                );
              },
              childCount: 4,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(strings.t('startTrial')),
          ),
        ),
      ),
    );
  }
}
