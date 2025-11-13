import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/widgets/metric_chip.dart';
import '../../core/widgets/skeleton_box.dart';
import '../settings/settings_page.dart';

class AdaptiveProgramPage extends StatefulWidget {
  const AdaptiveProgramPage({super.key});

  static const route = '/adaptive-program';

  @override
  State<AdaptiveProgramPage> createState() => _AdaptiveProgramPageState();
}

class _AdaptiveProgramPageState extends State<AdaptiveProgramPage>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _sparkleController;
  late final PageController _phaseController;
  final ValueNotifier<int> _activePhase = ValueNotifier<int>(0);
  final ValueNotifier<double> _weeklyLoad = ValueNotifier<double>(17);
  final ScrollController _scrollController = ScrollController();

  final List<_ProgramPhase> _phases = const [
    _ProgramPhase(
      titleKey: 'adaptivePhaseFoundation',
      subtitleKey: 'adaptivePhaseFoundationDesc',
      weeks: 3,
      loadFocus: 0.55,
      skillFocus: 0.65,
      readinessKey: 'adaptiveReadinessHigh',
      highlights: [
        'adaptiveHighlightMobility',
        'adaptiveHighlightResilience',
        'adaptiveHighlightCapacity',
      ],
    ),
    _ProgramPhase(
      titleKey: 'adaptivePhaseCapacity',
      subtitleKey: 'adaptivePhaseCapacityDesc',
      weeks: 4,
      loadFocus: 0.72,
      skillFocus: 0.58,
      readinessKey: 'adaptiveReadinessModerate',
      highlights: [
        'adaptiveHighlightVolume',
        'adaptiveHighlightTempo',
        'adaptiveHighlightRecovery',
      ],
    ),
    _ProgramPhase(
      titleKey: 'adaptivePhasePower',
      subtitleKey: 'adaptivePhasePowerDesc',
      weeks: 3,
      loadFocus: 0.82,
      skillFocus: 0.76,
      readinessKey: 'adaptiveReadinessHigh',
      highlights: [
        'adaptiveHighlightPower',
        'adaptiveHighlightVelocity',
        'adaptiveHighlightMindset',
      ],
    ),
    _ProgramPhase(
      titleKey: 'adaptivePhasePeak',
      subtitleKey: 'adaptivePhasePeakDesc',
      weeks: 2,
      loadFocus: 0.62,
      skillFocus: 0.88,
      readinessKey: 'adaptiveReadinessPrecision',
      highlights: [
        'adaptiveHighlightSharpness',
        'adaptiveHighlightRecovery',
        'adaptiveHighlightCelebration',
      ],
    ),
  ];

  final List<_DailyFocus> _dailyFocus = const [
    _DailyFocus(
      icon: Icons.bolt_rounded,
      titleKey: 'adaptiveFocusStrength',
      subtitleKey: 'adaptiveFocusStrengthDesc',
      accent: Color(0xFF22C55E),
    ),
    _DailyFocus(
      icon: Icons.fitness_center_rounded,
      titleKey: 'adaptiveFocusEndurance',
      subtitleKey: 'adaptiveFocusEnduranceDesc',
      accent: Color(0xFF6366F1),
    ),
    _DailyFocus(
      icon: Icons.self_improvement_rounded,
      titleKey: 'adaptiveFocusMobility',
      subtitleKey: 'adaptiveFocusMobilityDesc',
      accent: Color(0xFFEC4899),
    ),
    _DailyFocus(
      icon: Icons.bedtime_rounded,
      titleKey: 'adaptiveFocusRecovery',
      subtitleKey: 'adaptiveFocusRecoveryDesc',
      accent: Color(0xFFF59E0B),
    ),
  ];

  final List<_CoachBoost> _boosts = const [
    _CoachBoost(
      titleKey: 'adaptiveCoachBoostSleep',
      subtitleKey: 'adaptiveCoachBoostSleepDesc',
      icon: Icons.bed_outlined,
    ),
    _CoachBoost(
      titleKey: 'adaptiveCoachBoostNutrition',
      subtitleKey: 'adaptiveCoachBoostNutritionDesc',
      icon: Icons.restaurant_outlined,
    ),
    _CoachBoost(
      titleKey: 'adaptiveCoachBoostMindset',
      subtitleKey: 'adaptiveCoachBoostMindsetDesc',
      icon: Icons.psychology_alt_outlined,
    ),
  ];

  final List<_SessionTemplate> _templates = const [
    _SessionTemplate(
      titleKey: 'adaptiveSessionIntervals',
      subtitleKey: 'adaptiveSessionIntervalsDesc',
      duration: 42,
      zone: 'Z3',
    ),
    _SessionTemplate(
      titleKey: 'adaptiveSessionTempo',
      subtitleKey: 'adaptiveSessionTempoDesc',
      duration: 36,
      zone: 'Z4',
    ),
    _SessionTemplate(
      titleKey: 'adaptiveSessionSkill',
      subtitleKey: 'adaptiveSessionSkillDesc',
      duration: 28,
      zone: 'Skill',
    ),
    _SessionTemplate(
      titleKey: 'adaptiveSessionFlow',
      subtitleKey: 'adaptiveSessionFlowDesc',
      duration: 24,
      zone: 'Restore',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _phaseController = PageController(viewportFraction: 0.8);
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _sparkleController.dispose();
    _phaseController.dispose();
    _activePhase.dispose();
    _weeklyLoad.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAutoBuildSheet(AppLocalizations strings) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.t('adaptiveAutoBuild'),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  strings.t('adaptiveAutoBuildDescription'),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    MetricChip(
                      icon: Icons.calendar_today_rounded,
                      label: strings.t('adaptiveAutoMetricCycleLabel'),
                      value: '12',
                    ),
                    MetricChip(
                      icon: Icons.directions_run_rounded,
                      label: strings.t('adaptiveAutoMetricLoadLabel'),
                      value: strings.t('adaptiveAutoMetricLoadValue'),
                    ),
                    MetricChip(
                      icon: Icons.hourglass_bottom_rounded,
                      label: strings.t('adaptiveAutoMetricRestLabel'),
                      value: '2',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.auto_fix_high_rounded),
                  label: Text(strings.t('adaptiveAutoBuildStart')),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(strings.t('adaptiveAutoBuildCancel')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: colorScheme.surface,
            titleSpacing: 24,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: strings.t('settings'),
                onPressed: () => Navigator.pushNamed(context, SettingsPage.route),
                icon: const Icon(Icons.tune_rounded),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('adaptiveProgramTitle')),
                  const SizedBox(height: 4),
                  Text(
                    strings.t('adaptiveProgramSubtitle'),
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              background: AnimatedBuilder(
                animation: _breathingController,
                builder: (context, child) {
                  final progress = _breathingController.value;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.08 + progress * 0.12),
                          colorScheme.secondary.withOpacity(0.04 + (1 - progress) * 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _SparklePainter(
                        animation: _sparkleController,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('adaptiveProgramPhases'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: _phaseController,
                      itemCount: _phases.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) {
                        _activePhase.value = value;
                        _weeklyLoad.value = 16 + value * 2.5;
                      },
                      itemBuilder: (context, index) {
                        final phase = _phases[index];
                        return ValueListenableBuilder<int>(
                          valueListenable: _activePhase,
                          builder: (context, active, _) {
                            return AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                final t = _breathingController.value;
                                final scale = index == active ? 1 + t * 0.04 : 0.96;
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: _PhaseCard(strings: strings, phase: phase),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _activePhase,
                    builder: (context, active, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_phases.length, (index) {
                          final selected = index == active;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            height: 8,
                            width: selected ? 28 : 12,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colorScheme.primary.withOpacity(0.8)
                                  : colorScheme.primary.withOpacity(0.24),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('adaptiveLoadDistribution'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: _weeklyLoad,
                    builder: (context, load, _) {
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 420),
                        tween: Tween(begin: 0, end: load),
                        builder: (context, value, child) {
                          return _LoadVisualizer(
                            value: value,
                            theme: theme,
                            label: strings.t('adaptiveLoadLabel'),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(strings.t('adaptiveDailyFocus'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(strings.t('adaptiveDailyFocusSubtitle'), style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) {
                    final focus = _dailyFocus[index];
                    return _FocusCard(strings: strings, focus: focus);
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemCount: _dailyFocus.length,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('adaptiveCoachBoost'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(strings.t('adaptiveCoachBoostSubtitle'), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 12),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) {
                    final boost = _boosts[index];
                    return _BoostCard(strings: strings, boost: boost);
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: _boosts.length,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('adaptiveSessionTemplates'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(strings.t('adaptiveSessionTemplatesSubtitle'), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final template = _templates[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(24, index == 0 ? 0 : 12, 24, 12),
                  child: _SessionTemplateCard(strings: strings, template: template),
                );
              },
              childCount: _templates.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showAutoBuildSheet(strings),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_graph_rounded),
                    const SizedBox(width: 8),
                    Text(strings.t('adaptiveAutoBuild')),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: () {
                final snackBar = SnackBar(
                  content: Text(strings.t('adaptiveLastSync')),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Icon(Icons.sync_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.strings, required this.phase});

  final AppLocalizations strings;
  final _ProgramPhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t(phase.titleKey), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(strings.t(phase.subtitleKey), style: theme.textTheme.bodyMedium),
          const Spacer(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PhaseMetric(
                icon: Icons.auto_fix_high_rounded,
                label: strings.t('adaptivePhaseFocus'),
                value: strings.t(phase.readinessKey),
              ),
              _PhaseMetric(
                icon: Icons.calendar_today_rounded,
                label: strings.t('adaptivePhaseWeeksLabel').replaceFirst('{value}', phase.weeks.toString()),
                value: '${(phase.loadFocus * 100).round()}% ${strings.t('adaptivePhaseIntensity')}',
              ),
              _PhaseMetric(
                icon: Icons.workspace_premium_rounded,
                label: strings.t('adaptiveSkillFocus'),
                value: strings
                    .t('adaptiveSkillFocusValue')
                    .replaceFirst('{value}', (phase.skillFocus * 100).round().toString()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: phase.highlights
                .map(
                  (key) => Chip(
                    label: Text(strings.t(key)),
                    backgroundColor: colorScheme.primary.withOpacity(0.08),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PhaseMetric extends StatelessWidget {
  const _PhaseMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LoadVisualizer extends StatelessWidget {
  const _LoadVisualizer({
    required this.value,
    required this.theme,
    required this.label,
  });

  final double value;
  final ThemeData theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(7, (index) {
      final normalized = (value / 21).clamp(0.2, 1.0);
      final height = 24.0 + (index + 1) * 12 * normalized;
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.85),
                theme.colorScheme.primary.withOpacity(0.35 + index * 0.08),
              ],
            ),
          ),
          height: height,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${value.toStringAsFixed(1)} h • $label'),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(children: bars),
          ),
          const SizedBox(height: 12),
          const SkeletonBox(height: 4),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.strings, required this.focus});

  final AppLocalizations strings;
  final _DailyFocus focus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            focus.accent.withOpacity(0.12),
            focus.accent.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(focus.icon, color: focus.accent, size: 26),
          const SizedBox(height: 16),
          Text(strings.t(focus.titleKey), style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(strings.t(focus.subtitleKey), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BoostCard extends StatelessWidget {
  const _BoostCard({required this.strings, required this.boost});

  final AppLocalizations strings;
  final _CoachBoost boost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(boost.icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(strings.t(boost.titleKey), style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(strings.t(boost.subtitleKey), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SessionTemplateCard extends StatelessWidget {
  const _SessionTemplateCard({required this.strings, required this.template});

  final AppLocalizations strings;
  final _SessionTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t(template.titleKey), style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(strings.t(template.subtitleKey), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.primary.withOpacity(0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${template.duration} min', style: theme.textTheme.labelLarge),
                    Text(template.zone, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            minHeight: 6,
            value: math.min(1, template.duration / 60),
            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.animation, required this.color}) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final count = 14;
    for (var i = 0; i < count; i++) {
      final progress = (animation.value + i / count) % 1;
      final dx = size.width * progress;
      final dy = size.height * math.sin(progress * math.pi * 2) * 0.12 + size.height * 0.5;
      canvas.drawCircle(Offset(dx, dy), 18 - i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.animation != animation;
}

class _ProgramPhase {
  const _ProgramPhase({
    required this.titleKey,
    required this.subtitleKey,
    required this.weeks,
    required this.loadFocus,
    required this.skillFocus,
    required this.readinessKey,
    required this.highlights,
  });

  final String titleKey;
  final String subtitleKey;
  final int weeks;
  final double loadFocus;
  final double skillFocus;
  final String readinessKey;
  final List<String> highlights;
}

class _DailyFocus {
  const _DailyFocus({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.accent,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color accent;
}

class _CoachBoost {
  const _CoachBoost({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
  });

  final String titleKey;
  final String subtitleKey;
  final IconData icon;
}

class _SessionTemplate {
  const _SessionTemplate({
    required this.titleKey,
    required this.subtitleKey,
    required this.duration,
    required this.zone,
  });

  final String titleKey;
  final String subtitleKey;
  final int duration;
  final String zone;
}
