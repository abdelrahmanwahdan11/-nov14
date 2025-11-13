import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../data/models/user_profile.dart';
import '../profile/profile_controller.dart';
import '../shared/app_state.dart';

class WellnessStudioPage extends StatefulWidget {
  const WellnessStudioPage({super.key});

  static const route = '/wellness-studio';

  @override
  State<WellnessStudioPage> createState() => _WellnessStudioPageState();
}

class _WellnessStudioPageState extends State<WellnessStudioPage>
    with TickerProviderStateMixin {
  late final AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final controller = state.profileController;
    final strings = AppLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionSheet(context, controller, strings),
        icon: const Icon(Icons.add),
        label: Text(strings.t('wellnessActions')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final macroProgress = controller.macroProgressToday;
          final mindfulness = controller.mindfulnessSessions;
          final routines = controller.recoveryRoutines;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                stretch: true,
                title: Text(strings.t('wellnessStudio')),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.fadeTitle, StretchMode.zoomBackground],
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 120, 24, 32),
                    child: AnimatedBuilder(
                      animation: _heroController,
                      builder: (context, child) {
                        final value = CurvedAnimation(
                          parent: _heroController,
                          curve: Curves.easeOutCubic,
                        ).value;
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _HeroWellnessCard(
                              strings: strings,
                              controller: controller,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _NutritionSection(
                    strings: strings,
                    controller: controller,
                    macroProgress: macroProgress,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _SleepSection(strings: strings, records: controller.sleepRecords),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _MindfulnessSection(strings: strings, sessions: mindfulness),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: _RecoverySection(
                    strings: strings,
                    routines: routines,
                    onComplete: controller.completeRecoveryRoutine,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showActionSheet(
    BuildContext context,
    ProfileController controller,
    AppLocalizations strings,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(strings.t('wellnessActions'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _ActionSheetButton(
                icon: Icons.restaurant_outlined,
                label: strings.t('logSampleMeal'),
                onTap: () {
                  Navigator.pop(context);
                  _logSampleMeal(controller);
                },
              ),
              _ActionSheetButton(
                icon: Icons.bedtime_outlined,
                label: strings.t('logSampleSleep'),
                onTap: () {
                  Navigator.pop(context);
                  _logSampleSleep(controller);
                },
              ),
              _ActionSheetButton(
                icon: Icons.self_improvement_outlined,
                label: strings.t('logSampleMindfulness'),
                onTap: () {
                  Navigator.pop(context);
                  _logMindfulness(controller);
                },
              ),
              _ActionSheetButton(
                icon: Icons.favorite_outline,
                label: strings.t('completeRecoveryRoutine'),
                onTap: () {
                  Navigator.pop(context);
                  _completeRecovery(controller);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logSampleMeal(ProfileController controller) {
    final now = DateTime.now();
    final random = math.Random();
    final meals = [
      ('Power poke bowl', 620, 48, 58, 18),
      ('Recovery smoothie', 360, 28, 42, 9),
      ('High-protein oats', 450, 32, 50, 12),
    ];
    final sample = meals[random.nextInt(meals.length)];
    controller.logMeal(
      NutritionLog(
        timestamp: now,
        mealType: sample.$1,
        calories: sample.$2,
        protein: sample.$3,
        carbs: sample.$4,
        fats: sample.$5,
        mood: 'Refuelled',
      ),
    );
  }

  void _logSampleSleep(ProfileController controller) {
    final now = DateTime.now();
    final hours = 6.8 + math.Random().nextDouble() * 2.2;
    controller.logSleep(
      SleepRecord(
        date: now,
        hours: double.parse(hours.toStringAsFixed(1)),
        quality: 78 + math.Random().nextInt(12),
        readinessImpact: 74 + math.Random().nextInt(10),
      ),
    );
  }

  void _logMindfulness(ProfileController controller) {
    final techniques = ['Box breathing', 'Yoga nidra', 'Visualization'];
    final moods = ['Calm', 'Grounded', 'Inspired'];
    final random = math.Random();
    controller.addMindfulnessSession(
      MindfulnessSession(
        date: DateTime.now(),
        durationMinutes: 5 + random.nextInt(6),
        technique: techniques[random.nextInt(techniques.length)],
        moodAfter: moods[random.nextInt(moods.length)],
      ),
    );
  }

  void _completeRecovery(ProfileController controller) {
    final next = controller.nextRecoveryRoutine;
    if (next == null) return;
    controller.completeRecoveryRoutine(next.id);
  }
}

class _HeroWellnessCard extends StatelessWidget {
  const _HeroWellnessCard({required this.strings, required this.controller});

  final AppLocalizations strings;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final macroTargets = controller.macroTargets;
    final progress = controller.calorieProgressToday;
    final latestSleep = controller.latestSleep;
    final mindfulnessMinutes = controller.mindfulnessMinutesWeek;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(.18),
            theme.colorScheme.secondary.withOpacity(.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('wellnessHighlights'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(value * 100).clamp(0, 130).toStringAsFixed(0)}% ${strings.t('calorieIntakeToday')}',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: value.clamp(0, 1.2),
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.surface.withOpacity(.3),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: Icons.restaurant,
                  label: strings.t('macroTargets'),
                  value: '${macroTargets.calories} kcal | ${macroTargets.protein}g P',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HeroMetric(
                  icon: Icons.nightlight_round,
                  label: strings.t('sleepConsistency'),
                  value: latestSleep == null
                      ? strings.t('noData')
                      : '${latestSleep.hours.toStringAsFixed(1)} h · ${latestSleep.quality}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HeroMetric(
            icon: Icons.self_improvement,
            label: strings.t('mindfulnessMinutes'),
            value: '${mindfulnessMinutes.toStringAsFixed(0)} ${strings.t('minutes')}',
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({
    required this.strings,
    required this.controller,
    required this.macroProgress,
  });

  final AppLocalizations strings;
  final ProfileController controller;
  final Map<String, double> macroProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.t('nutrition'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.t('dailyMacros'), style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              _MacroBar(
                label: strings.t('protein'),
                progress: macroProgress['protein'] ?? 0.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _MacroBar(
                label: strings.t('carbs'),
                progress: macroProgress['carbs'] ?? 0.0,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              _MacroBar(
                label: strings.t('fats'),
                progress: macroProgress['fats'] ?? 0.0,
                color: theme.colorScheme.errorContainer,
              ),
              const SizedBox(height: 16),
              ...controller.nutritionLogs.take(3).map(
                    (log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.restaurant, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.mealType, style: theme.textTheme.bodyMedium),
                                Text(
                                  '${log.calories} kcal · ${log.protein}P/${log.carbs}C/${log.fats}F',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (log.mood != null)
                            Text(log.mood!, style: theme.textTheme.bodySmall),
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

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.label, required this.progress, required this.color});

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text('${(progress * 100).clamp(0, 140).toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1.2),
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.3),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _SleepSection extends StatelessWidget {
  const _SleepSection({required this.strings, required this.records});

  final AppLocalizations strings;
  final List<SleepRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.t('sleep'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: records.take(5).map((record) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.nightlight_round, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatDate(record.date)} · ${record.hours.toStringAsFixed(1)}h',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${strings.t('quality')}: ${record.quality} · ${strings.t('readiness')}: ${record.readinessImpact}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.timeline, color: theme.colorScheme.secondary),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _MindfulnessSection extends StatelessWidget {
  const _MindfulnessSection({required this.strings, required this.sessions});

  final AppLocalizations strings;
  final List<MindfulnessSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.t('mindfulness'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Container(
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary.withOpacity(.14),
                      theme.colorScheme.primary.withOpacity(.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(IconlyLight.activity, color: theme.colorScheme.primary),
                    const Spacer(),
                    Text('${session.durationMinutes} ${strings.t('minutes')}',
                        style: theme.textTheme.titleMedium),
                    Text(session.technique, style: theme.textTheme.bodySmall),
                    Text(session.moodAfter, style: theme.textTheme.bodySmall),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: math.min(sessions.length, 10),
          ),
        ),
      ],
    );
  }
}

class _RecoverySection extends StatelessWidget {
  const _RecoverySection({
    required this.strings,
    required this.routines,
    required this.onComplete,
  });

  final AppLocalizations strings;
  final List<RecoveryRoutine> routines;
  final void Function(String id) onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.t('recovery'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Column(
          children: routines.map((routine) {
            final scheduled = routine.scheduledFor;
            final subtitle = scheduled == null
                ? strings.t('recoveryFocus')
                : '${strings.t('scheduledFor')} ${scheduled.month}/${scheduled.day}';
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(.08),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.primary.withOpacity(.12),
                    ),
                    child: const Icon(Icons.healing),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(routine.title, style: theme.textTheme.titleSmall),
                        Text(
                          '$subtitle · ${routine.durationMinutes} ${strings.t('minutes')}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '${strings.t('streak')}: ${routine.streak}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onComplete(routine.id),
                    child: Text(strings.t('markAsComplete')),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionSheetButton extends StatelessWidget {
  const _ActionSheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: theme.textTheme.titleSmall),
        ),
      ),
    );
  }
}
