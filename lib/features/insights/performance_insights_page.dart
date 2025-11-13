import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../data/models/user_profile.dart';
import '../profile/profile_controller.dart';
import '../shared/app_state.dart';

class PerformanceInsightsPage extends StatelessWidget {
  const PerformanceInsightsPage({super.key});

  static const route = '/insights';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: state.profileController,
      builder: (context, _) {
        final controller = state.profileController;
        final trends = controller.performanceTrends;
        final milestones = controller.performanceMilestones;
        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 260,
                title: Text(strings.t('performanceInsights')),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.fadeTitle, StretchMode.blurBackground],
                  background: _InsightsHeader(
                    controller: controller,
                    strings: strings,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.t('performanceInsightsSubtitle'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _TrendCarousel(trends: trends, strings: strings),
                      const SizedBox(height: 28),
                      _FocusCard(controller: controller, strings: strings),
                      const SizedBox(height: 28),
                      Text(strings.t('milestoneCelebrations'), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (milestones.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _EmptyMilestones(strings: strings),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final milestone = milestones[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          index == 0 ? 0 : 12,
                          24,
                          index == milestones.length - 1 ? 32 : 0,
                        ),
                        child: _MilestoneTile(
                          milestone: milestone,
                          strings: strings,
                          onComplete: () => controller.completeMilestone(milestone.id),
                        ),
                      );
                    },
                    childCount: milestones.length,
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _simulateBurst(context, controller, strings),
            icon: const Icon(Icons.timeline_rounded),
            label: Text(strings.t('simulateSession')),
          ),
        );
      },
    );
  }
}

class _InsightsHeader extends StatelessWidget {
  const _InsightsHeader({required this.controller, required this.strings});

  final ProfileController controller;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final top = controller.topMomentum;
    final lagging = controller.laggingTrend;
    final locale = MaterialLocalizations.of(context);
    final updatedLabel = strings.t('lastUpdated');
    final updatedTime = locale.formatShortDateTime(controller.performanceTrends.isEmpty
        ? DateTime.now()
        : controller.performanceTrends.first.lastUpdated);
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(.85),
                theme.colorScheme.primary.withOpacity(.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 48,
          left: 24,
          right: 24,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.t('performanceHighlights').toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onPrimary.withOpacity(.78),
                    letterSpacing: 1.1,
                  )),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  controller.overallPerformanceScore.toStringAsFixed(1),
                  key: ValueKey(controller.overallPerformanceScore),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(strings.t('loadScore'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onPrimary.withOpacity(.78),
                  )),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _HeaderTile(
                      icon: Icons.trending_up_rounded,
                      label: strings.t('momentumScore'),
                      value: controller.momentumScore.toStringAsFixed(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (top != null)
                    Expanded(
                      child: _HeaderTile(
                        icon: Icons.auto_graph_rounded,
                        label: strings.t('momentumLeader'),
                        value: strings.t(top.metric),
                        delta: top.weekChange,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (lagging != null)
                _HeaderTag(
                  icon: Icons.adjust_rounded,
                  label: strings.t('laggingPillar'),
                  value: strings.t(lagging.metric),
                ),
              const SizedBox(height: 12),
              Text('$updatedLabel · $updatedTime',
                  style: theme.textTheme.labelSmall?.copyWith(color: onPrimary.withOpacity(.72))),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderTile extends StatelessWidget {
  const _HeaderTile({
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final deltaValue = delta == null
        ? null
        : '${delta! >= 0 ? '+' : ''}${delta!.toStringAsFixed(1)}';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.onPrimary.withOpacity(.08),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: onPrimary.withOpacity(.85)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(color: onPrimary.withOpacity(.85)),
                  ),
                ),
                if (deltaValue != null)
                  Text(
                    deltaValue,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: delta! >= 0 ? Colors.lightGreenAccent : Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.onPrimary.withOpacity(.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: onPrimary.withOpacity(.85)),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: onPrimary.withOpacity(.78))),
          const SizedBox(width: 8),
          Text(value, style: theme.textTheme.labelLarge?.copyWith(color: onPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TrendCarousel extends StatefulWidget {
  const _TrendCarousel({required this.trends, required this.strings});

  final List<PerformanceTrend> trends;
  final AppLocalizations strings;

  @override
  State<_TrendCarousel> createState() => _TrendCarouselState();
}

class _TrendCarouselState extends State<_TrendCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: .82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trends.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.trends.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1;
              if (_pageController.hasClients && _pageController.position.haveDimensions) {
                final page = _pageController.page ?? _pageController.initialPage.toDouble();
                final distance = (page - index).abs();
                scale = (1 - distance * 0.12).clamp(.85, 1.0);
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _TrendCard(trend: widget.trends[index], strings: widget.strings),
          );
        },
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend, required this.strings});

  final PerformanceTrend trend;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestValue = trend.points.isEmpty ? 0 : trend.points.first.value;
    final weekDelta = trend.weekChange;
    final monthDelta = trend.monthChange;
    final deltaStyle = theme.textTheme.labelLarge;
    final chartColor = theme.colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(.12),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t(trend.metric), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(strings.t('weekChange'), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    Text(
                      '${weekDelta >= 0 ? '+' : ''}${weekDelta.toStringAsFixed(1)}',
                      style: deltaStyle?.copyWith(
                        color: weekDelta >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${latestValue.toStringAsFixed(1)}',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(strings.t('monthChange'),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  Text(
                    '${monthDelta >= 0 ? '+' : ''}${monthDelta.toStringAsFixed(1)}',
                    style: deltaStyle?.copyWith(
                      color: monthDelta >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _TrendChart(points: trend.points, color: chartColor),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.color});

  final List<TrendPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }
    final sorted = points.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final values = sorted.map((p) => p.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < .01 ? 1 : (maxValue - minValue);
    final normalized = values.map((value) => (value - minValue) / range).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return CustomPaint(
            size: size,
            painter: _TrendChartPainter(normalized: normalized, color: color.withOpacity(.9)),
          );
        },
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({required this.normalized, required this.color});

  final List<double> normalized;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (normalized.length < 2) return;
    final path = Path();
    final step = size.width / (normalized.length - 1);
    path.moveTo(0, size.height - normalized.first * size.height);
    for (var i = 1; i < normalized.length; i++) {
      final x = step * i;
      final y = size.height - normalized[i] * size.height;
      path.lineTo(x, y);
    }
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(.55), color.withOpacity(.08)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.normalized != normalized || oldDelegate.color != color;
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.controller, required this.strings});

  final ProfileController controller;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusKey = controller.recommendedFocusKey;
    final top = controller.topMomentum;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surfaceVariant.withOpacity(.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(IconlyLight.graph, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(strings.t('weeklyFocus'), style: theme.textTheme.titleMedium),
              const Spacer(),
              if (top != null)
                Chip(
                  label: Text(strings.t('momentumLeader')),
                  avatar: const Icon(Icons.trending_up_rounded, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${strings.t('focusOn')} ${strings.t(focusKey)}',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            strings.t('weeklyFocusSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.performanceTrends
                .map(
                  (trend) => _FocusPill(
                    label: strings.t(trend.metric),
                    score: trend.points.isEmpty ? 0 : trend.points.first.value,
                    active: trend.metric == focusKey,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FocusPill extends StatelessWidget {
  const _FocusPill({required this.label, required this.score, this.active = false});

  final String label;
  final double score;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(.24);
    final textColor = active ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(score.toStringAsFixed(1), style: theme.textTheme.labelLarge?.copyWith(color: textColor.withOpacity(.86))),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.strings,
    required this.onComplete,
  });

  final PerformanceMilestone milestone;
  final AppLocalizations strings;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achieved = milestone.achieved;
    final badgeColor = achieved ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final locale = MaterialLocalizations.of(context);
    final statusLabel = achieved ? strings.t('achieved') : strings.t('scheduled');
    final dateLabel = achieved && milestone.achievedOn != null
        ? locale.formatFullDate(milestone.achievedOn!)
        : locale.formatMediumDate(milestone.scheduledFor);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: achieved ? theme.colorScheme.primary.withOpacity(.35) : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: badgeColor.withOpacity(.16),
                ),
                child: Text(
                  milestone.badge,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                achieved ? Icons.verified_rounded : Icons.flag_rounded,
                color: achieved ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(milestone.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            milestone.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('$statusLabel · $dateLabel',
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              if (!achieved)
                TextButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(strings.t('markAsComplete')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMilestones extends StatelessWidget {
  const _EmptyMilestones({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 48),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconlyLight.calendar, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(strings.t('noMilestones'), textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

void _simulateBurst(
  BuildContext context,
  ProfileController controller,
  AppLocalizations strings,
) {
  if (controller.performanceTrends.isEmpty) return;
  final random = math.Random();
  final trend = controller.performanceTrends[random.nextInt(controller.performanceTrends.length)];
  final latest = trend.points.isEmpty ? 82 : trend.points.first.value;
  final boost = 0.6 + random.nextDouble() * 1.8;
  final newScore = (latest + boost).clamp(70, 100);
  controller.addTrainingSample(metric: trend.metric, score: newScore);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${strings.t('sessionSimulated')} ${strings.t(trend.metric)}'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
