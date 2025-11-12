import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/metric_chip.dart';
import '../../data/models/catalog_item.dart';
import '../compare/compare_page.dart';

class CatalogDetailPage extends StatefulWidget {
  const CatalogDetailPage({super.key, required this.item});

  static const route = '/catalog/detail';

  final CatalogItem item;

  @override
  State<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends State<CatalogDetailPage> {
  final ValueNotifier<Offset> _tilt = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _tilt.dispose();
    super.dispose();
  }

  void _handlePointer(PointerEvent event, Size size) {
    final local = event.localPosition;
    final dx = (local.dx / size.width) - .5;
    final dy = (local.dy / size.height) - .5;
    _tilt.value = Offset(dx, dy);
  }

  void _resetTilt() {
    _tilt.value = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = widget.item;

    final muscles = item.targetMuscles.isEmpty
        ? const ['Core', 'Mobility', 'Full body']
        : item.targetMuscles;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, ComparePage.route, arguments: [item]),
        label: Text(strings.t('compareNow')),
        icon: const Icon(Icons.table_view_rounded),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(item.name),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: const AiInfoButton(),
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 24, right: 24, bottom: 24),
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        final size = Size(boxConstraints.maxWidth, boxConstraints.maxHeight);
                        return Listener(
                          onPointerMove: (event) => _handlePointer(event, size),
                          onPointerHover: (event) => _handlePointer(event, size),
                          onPointerUp: (_) => _resetTilt(),
                          onPointerCancel: (_) => _resetTilt(),
                          child: ValueListenableBuilder<Offset>(
                            valueListenable: _tilt,
                            builder: (context, tilt, child) {
                              final rotationX = tilt.dy * -.4;
                              final rotationY = tilt.dx * .6;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 40,
                                      color: theme.colorScheme.primary.withOpacity(.18),
                                      offset: const Offset(0, 28),
                                    ),
                                  ],
                                ),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(rotationX)
                                    ..rotateY(rotationY),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Hero(
                                      tag: 'catalog-${item.id}',
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(item.imageUrl, fit: BoxFit.cover),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(.72),
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          color: theme.colorScheme.primary,
                                                          borderRadius: BorderRadius.circular(999),
                                                        ),
                                                        child: Text('PRO', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text('${item.metrics.timeMin}${strings.t('minutes')}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(item.name, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 6),
                                                  Text(item.description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      MetricChip(icon: IconlyBold.time_circle, label: strings.t('duration'), value: '${item.metrics.timeMin} ${strings.t('minutes')}'),
                      MetricChip(icon: IconlyBold.activity, label: strings.t('intensity'), value: strings.t('level') + ' ${item.metrics.level}'),
                      MetricChip(icon: IconlyBold.calories, label: strings.t('calories'), value: '${item.metrics.kcal} kcal'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(strings.t('overview'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    '${strings.t('sessionFocus')}\n${item.description}',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text(strings.t('targets'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      for (final muscle in muscles)
                        Chip(
                          label: Text(muscle),
                          backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(.6),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(strings.t('coachingTips'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _TipCard(
                    icon: IconlyLight.activity,
                    title: strings.t('warmupTip'),
                    description: strings.t('warmupTipBody'),
                  ),
                  const SizedBox(height: 12),
                  _TipCard(
                    icon: IconlyLight.danger,
                    title: strings.t('injuryTip'),
                    description: strings.t('injuryTipBody'),
                  ),
                  const SizedBox(height: 32),
                  Text(strings.t('equipment'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _EquipmentList(strings: strings),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('segments'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _SegmentTimeline(duration: item.metrics.timeMin),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('recommendedPairings'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final gradient = [
                          [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                          [theme.colorScheme.secondary, theme.colorScheme.secondaryContainer],
                          [theme.colorScheme.tertiary, theme.colorScheme.tertiaryContainer],
                        ][index % 3];
                        final titles = [strings.t('mobility'), strings.t('cardio'), strings.t('focusRecovery')];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(colors: gradient),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(titles[index % titles.length], style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                                const Spacer(),
                                FilledButton.tonal(
                                  onPressed: () {},
                                  child: Text(strings.t('startNow')),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, ComparePage.route, arguments: [item]),
                  child: Text(strings.t('addToCompare')),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: Text(strings.t('startWorkout')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(.08), blurRadius: 20, offset: const Offset(0, 16)),
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
                Text(description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentList extends StatelessWidget {
  const _EquipmentList({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final equipments = [
      strings.t('mat'),
      strings.t('dumbbells'),
      strings.t('resistanceBand'),
    ];
    return Column(
      children: [
        for (final equipment in equipments)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            leading: const Icon(Icons.check_circle_outline_rounded),
            title: Text(equipment),
            subtitle: Text(strings.t('includedEquipment')),
            trailing: IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          ),
        const SizedBox(height: 8),
        Text(strings.t('equipmentNote'), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}

class _SegmentTimeline extends StatelessWidget {
  const _SegmentTimeline({required this.duration});

  final int duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = [
      _Segment(label: 'Warm-up', minutes: (duration * .2).round()),
      _Segment(label: 'Main set', minutes: (duration * .6).round()),
      _Segment(label: 'Finisher', minutes: math.max(5, (duration * .2).round())),
    ];
    return Column(
      children: [
        for (var i = 0; i < segments.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == segments.length - 1 ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(radius: 10, backgroundColor: theme.colorScheme.primary),
                    if (i != segments.length - 1)
                      Container(width: 2, height: 48, color: theme.colorScheme.primary.withOpacity(.4)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(segments[i].label, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('${segments[i].minutes} ${AppLocalizations.of(context).t('minutes')}'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: segments[i].minutes / duration,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Segment {
  _Segment({required this.label, required this.minutes});

  final String label;
  final int minutes;
}
