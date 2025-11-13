import 'package:flutter/material.dart';

import '../../app/localization.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  static const route = '/plans';

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final PageController _levelController = PageController(viewportFraction: 0.86);
  final ValueNotifier<int> _selectedDay = ValueNotifier<int>(DateTime.now().weekday % 7);
  final List<_PlanDay> _week = const [
    _PlanDay(label: 'Mon', focus: 'Mobility Flow', duration: 25, typeKey: 'mobility'),
    _PlanDay(label: 'Tue', focus: 'Endurance Ride', duration: 40, typeKey: 'cardio'),
    _PlanDay(label: 'Wed', focus: 'Strength Blocks', duration: 45, typeKey: 'train'),
    _PlanDay(label: 'Thu', focus: 'Recovery Walk', duration: 30, typeKey: 'focusRecovery'),
    _PlanDay(label: 'Fri', focus: 'Tempo Run', duration: 35, typeKey: 'cardio'),
    _PlanDay(label: 'Sat', focus: 'HIIT Ladder', duration: 28, typeKey: 'train'),
    _PlanDay(label: 'Sun', focus: 'Rest', duration: 0, typeKey: 'restDay'),
  ];

  @override
  void dispose() {
    _levelController.dispose();
    _selectedDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('plans'))),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _levelController,
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final label = levels[index];
                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 320),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withOpacity(.1),
                            blurRadius: 24,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            Text(strings.t('weeklyPlanner')),
                            const Spacer(),
                            FilledButton(
                              onPressed: () {},
                              child: Text(strings.t('continuePlan')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(strings.t('tapToEdit'), style: theme.textTheme.labelLarge),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedDay,
                builder: (context, selected, _) {
                  return Wrap(
                    spacing: 12,
                    children: [
                      for (var i = 0; i < _week.length; i++)
                        _DayChip(
                          day: _week[i],
                          selected: selected == i,
                          onTap: () => _selectedDay.value = i,
                          strings: strings,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedDay,
                builder: (context, selected, _) {
                  final day = _week[selected];
                  final label = day.typeKey == 'restDay' ? strings.t('restDay') : strings.t(day.typeKey);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 340),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(.1),
                          blurRadius: 24,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day.label, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(label, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 20),
                        if (day.duration > 0)
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined),
                              const SizedBox(width: 8),
                              Text('${day.duration} ${strings.t('minutes')}'),
                            ],
                          )
                        else
                          Text(strings.t('restDay')),
                        const SizedBox(height: 24),
                        LinearProgressIndicator(value: day.duration == 0 ? 0 : (day.duration / 60).clamp(0, 1)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected, required this.onTap, required this.strings});

  final _PlanDay day;
  final bool selected;
  final VoidCallback onTap;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: selected ? theme.colorScheme.primary.withOpacity(.2) : theme.colorScheme.surfaceVariant.withOpacity(.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(day.label, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(day.focus, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanDay {
  const _PlanDay({required this.label, required this.focus, required this.duration, required this.typeKey});

  final String label;
  final String focus;
  final int duration;
  final String typeKey;
}
