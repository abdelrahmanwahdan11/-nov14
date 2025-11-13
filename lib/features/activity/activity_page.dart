import 'package:flutter/material.dart';

import '../../app/localization.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  static const route = '/activity';

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final ValueNotifier<int> _segment = ValueNotifier<int>(0);
  final List<_ActivityDay> _days = const [
    _ActivityDay(
      labelKey: 'today',
      sessions: [
        _ActivitySession(title: 'Sunrise Run', time: '06:10', distanceKm: 5.2, minutes: 32, heart: 142, steps: 6420, intensity: .7),
        _ActivitySession(title: 'Mobility Flow', time: '12:40', distanceKm: 0.0, minutes: 18, heart: 104, steps: 1200, intensity: .4),
      ],
    ),
    _ActivityDay(
      labelKey: 'yesterday',
      sessions: [
        _ActivitySession(title: 'HIIT Ignite', time: '19:10', distanceKm: 3.1, minutes: 24, heart: 158, steps: 5120, intensity: .9),
        _ActivitySession(title: 'Recovery Walk', time: '21:00', distanceKm: 2.6, minutes: 22, heart: 118, steps: 4300, intensity: .5),
      ],
    ),
    _ActivityDay(
      labelKey: 'completed',
      sessions: [
        _ActivitySession(title: 'Strength Ladder', time: '07:30', distanceKm: 0.0, minutes: 45, heart: 152, steps: 3100, intensity: .85),
      ],
    ),
  ];

  @override
  void dispose() {
    _segment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('activity'))),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: strings.t('completed'),
                      value: '5',
                      subtitle: strings.t('weeklySummary'),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: strings.t('remaining'),
                      value: '2',
                      subtitle: strings.t('upcomingSessions'),
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ValueListenableBuilder<int>(
                valueListenable: _segment,
                builder: (context, index, _) {
                  return SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text(strings.t('timeline'))),
                      ButtonSegment(value: 1, label: Text(strings.t('focusRecovery'))),
                      ButtonSegment(value: 2, label: Text(strings.t('progress'))),
                    ],
                    selected: {index},
                    onSelectionChanged: (value) => _segment.value = value.first,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
            sliver: ValueListenableBuilder<int>(
              valueListenable: _segment,
              builder: (context, index, _) {
                if (index == 1) {
                  return SliverToBoxAdapter(child: _RecoveryCard(strings: strings));
                }
                if (index == 2) {
                  return SliverToBoxAdapter(child: _ProgressChart(strings: strings));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, dayIndex) {
                      final day = _days[dayIndex];
                      return _TimelineSection(day: day, strings: strings);
                    },
                    childCount: _days.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value, required this.subtitle, required this.color});

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [color.withOpacity(.15), theme.colorScheme.surface]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.day, required this.strings});

  final _ActivityDay day;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t(day.labelKey), style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          for (var i = 0; i < day.sessions.length; i++)
            _TimelineTile(
              session: day.sessions[i],
              isFirst: i == 0,
              isLast: i == day.sessions.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.session, required this.isFirst, required this.isLast});

  final _ActivitySession session;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 40, end: 0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(.8),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [theme.colorScheme.primary.withOpacity(.3), theme.colorScheme.primary.withOpacity(.05)],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(.08),
                      blurRadius: 22,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(session.title, style: theme.textTheme.titleMedium),
                          Text(session.time, style: theme.textTheme.labelLarge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _InfoPill(icon: Icons.timer_outlined, label: '${session.minutes} min'),
                          if (session.distanceKm > 0)
                            _InfoPill(icon: Icons.route_outlined, label: '${session.distanceKm.toStringAsFixed(1)} km'),
                          _InfoPill(icon: Icons.favorite_outline, label: '${session.heart} bpm'),
                          _InfoPill(icon: Icons.directions_walk, label: '${session.steps} steps'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: session.intensity,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.3),
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceVariant.withOpacity(.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(colors: [theme.colorScheme.tertiary.withOpacity(.18), theme.colorScheme.surface]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('focusRecovery'), style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(strings.t('hydrationReminder'), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(value: .62, minHeight: 12),
          ),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(.08),
            blurRadius: 24,
            offset: const Offset(0, 18),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('progress'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineChartPainter(theme.colorScheme.primary),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final points = [0.0, 0.18, 0.1, 0.42, 0.35, 0.6, 0.55, 0.8, 0.65, 0.9];
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => oldDelegate.color != color;
}

class _ActivityDay {
  const _ActivityDay({required this.labelKey, required this.sessions});

  final String labelKey;
  final List<_ActivitySession> sessions;
}

class _ActivitySession {
  const _ActivitySession({
    required this.title,
    required this.time,
    required this.distanceKm,
    required this.minutes,
    required this.heart,
    required this.steps,
    required this.intensity,
  });

  final String title;
  final String time;
  final double distanceKm;
  final int minutes;
  final int heart;
  final int steps;
  final double intensity;
}
