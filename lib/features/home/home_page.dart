import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/metric_chip.dart';
import '../../core/widgets/skeleton_box.dart';
import '../activity/activity_page.dart';
import '../catalog/catalog_page.dart';
import '../community/community_page.dart';
import '../help/help_page.dart';
import '../insights/performance_insights_page.dart';
import '../paywall/paywall_page.dart';
import '../plans/plans_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import '../train/train_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final PageController _heroController;
  late final AnimationController _pulseController;
  final ValueNotifier<int> _focusIndex = ValueNotifier<int>(0);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _hydrationNotifier = ValueNotifier<double>(0.58);
  final ValueNotifier<double> _readinessNotifier = ValueNotifier<double>(0.74);
  final StreamController<_LiveStat> _liveStats = StreamController<_LiveStat>.broadcast();
  Timer? _heroTimer;
  Timer? _metricsTimer;
  bool _loading = true;

  final List<_HeroStory> _stories = const [
    _HeroStory(
      image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
      title: 'Mobility Flow',
      subtitle: '15 ${_HeroStory.minutesTag}',
      badge: 'PRO',
    ),
    _HeroStory(
      image: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
      title: 'HIIT Ignite',
      subtitle: '24 ${_HeroStory.minutesTag}',
      badge: 'LIVE',
    ),
    _HeroStory(
      image: 'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
      title: 'Strength Ladder',
      subtitle: '40 ${_HeroStory.minutesTag}',
      badge: 'COACH',
    ),
  ];

  final List<_UpcomingSession> _upcoming = const [
    _UpcomingSession(title: 'Sunrise run', subtitle: '05:30 · Zone 2', duration: 32, focus: 'Endurance'),
    _UpcomingSession(title: 'Mobility reset', subtitle: '12:15 · Studio', duration: 20, focus: 'Mobility'),
    _UpcomingSession(title: 'Strength power', subtitle: '19:00 · Gym', duration: 45, focus: 'Power'),
  ];

  @override
  void initState() {
    super.initState();
    _heroController = PageController(viewportFraction: 0.88);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _startHeroAutoPlay();
    _seedLiveStats();
    Future.delayed(const Duration(milliseconds: 640), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _startHeroAutoPlay() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_heroController.hasClients) return;
      final next = ((_heroController.page ?? 0).round() + 1) % _stories.length;
      _heroController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _seedLiveStats() {
    int steps = 4520;
    int calories = 320;
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      steps += 16;
      calories += timer.tick.isEven ? 1 : 0;
      _liveStats.add(_LiveStat(steps: steps, calories: calories));
      final hydration = (_hydrationNotifier.value + 0.002).clamp(0.0, 1.0);
      final readiness = 0.68 + math.sin(timer.tick / 3.5) * 0.08;
      _hydrationNotifier.value = hydration;
      _readinessNotifier.value = readiness.clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _metricsTimer?.cancel();
    _heroController.dispose();
    _pulseController.dispose();
    _focusIndex.dispose();
    _scrollController.dispose();
    _hydrationNotifier.dispose();
    _readinessNotifier.dispose();
    _liveStats.close();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _seedLiveStats();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 360,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(strings.t('home')),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => Navigator.pushNamed(context, SearchPage.route),
                ),
                IconButton(
                  icon: const Icon(Icons.workspace_premium_outlined),
                  onPressed: () => Navigator.pushNamed(context, PaywallPage.route),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 24, bottom: 32),
                  child: PageView.builder(
                    controller: _heroController,
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      final story = _stories[index];
                      return AnimatedPadding(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _loading
                            ? const SkeletonBox()
                            : Parallax3DCard(
                                image: story.image,
                                title: story.title,
                                subtitle: story.subtitle,
                                badge: story.badge,
                                onTap: () => Navigator.pushNamed(context, CatalogPage.route),
                              ),
                      );
                    },
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: AnimatedBuilder(
                  animation: _heroController,
                  builder: (context, _) {
                    final active = (_heroController.page ?? _heroController.initialPage.toDouble()).round();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _stories.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: i == active ? 28 : 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: theme.colorScheme.primary.withOpacity(i == active ? 0.9 : 0.3),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Hero(
                tag: 'global-search-field',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, SearchPage.route),
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(.06),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.t('searchHint'),
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                            ),
                          ),
                          Text(
                            strings.t('advancedSearch'),
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t('dailyFocus'), style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _loading
                        ? const SkeletonBox(height: 140)
                          : ValueListenableBuilder<double>(
                              valueListenable: _readinessNotifier,
                              builder: (context, readiness, _) {
                                return _StatCard(
                                  title: strings.t('readinessScore'),
                                  subtitle: strings.t('weeklySummary'),
                                  value: (readiness * 100).round(),
                                  trailing: _AnimatedBadge(
                                    controller: _pulseController,
                                    label: strings.t('progress'),
                                  ),
                                );
                              },
                            ),
                    const SizedBox(height: 16),
                    _loading
                        ? const SkeletonBox(height: 120)
                        : ValueListenableBuilder<double>(
                            valueListenable: _hydrationNotifier,
                            builder: (context, hydration, _) {
                              return _HydrationCard(
                                hydration: hydration,
                                strings: strings,
                              );
                            },
                          ),
                    const SizedBox(height: 16),
                    StreamBuilder<_LiveStat>(
                      stream: _liveStats.stream,
                      builder: (context, snapshot) {
                        final stat = snapshot.data ?? const _LiveStat(steps: 4500, calories: 320);
                        return _LiveRow(stat: stat, strings: strings);
                      },
                    ),
                    const SizedBox(height: 28),
                    ValueListenableBuilder<int>(
                      valueListenable: _focusIndex,
                      builder: (context, index, _) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _FocusChip(
                              label: strings.t('cardio'),
                              icon: IconlyLight.activity,
                              selected: index == 0,
                              onTap: () => _focusIndex.value = 0,
                            ),
                            _FocusChip(
                              label: strings.t('mobility'),
                              icon: IconlyLight.work,
                              selected: index == 1,
                              onTap: () => _focusIndex.value = 1,
                            ),
                            _FocusChip(
                              label: strings.t('focusRecovery'),
                              icon: IconlyLight.shield_done,
                              selected: index == 2,
                              onTap: () => _focusIndex.value = 2,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(strings.t('upcomingSessions'), style: theme.textTheme.titleMedium),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, ActivityPage.route),
                          child: Text(strings.t('viewAll')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final session = _upcoming[index];
                  return _SessionTile(session: session, delay: Duration(milliseconds: 120 * index));
                },
                childCount: _upcoming.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t('quickActions'), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.play_arrow_rounded,
                            label: strings.t('resumeWorkout'),
                            onTap: () => Navigator.pushNamed(context, TrainPage.route),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.insights_rounded,
                            label: strings.t('performanceInsights'),
                            onTap: () => Navigator.pushNamed(context, PerformanceInsightsPage.route),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.flash_on_rounded,
                            label: strings.t('startQuickSession'),
                            onTap: () => Navigator.pushNamed(context, CatalogPage.route),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.workspace_premium_rounded,
                            label: strings.t('unlockPro'),
                            onTap: () => Navigator.pushNamed(context, PaywallPage.route),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.help_outline_rounded,
                            label: strings.t('helpCenter'),
                            onTap: () => Navigator.pushNamed(context, HelpPage.route),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.track_changes_outlined,
                            label: strings.t('activity'),
                            onTap: () => Navigator.pushNamed(context, ActivityPage.route),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        MetricChip(icon: Icons.bolt_outlined, label: 'VO₂', value: '46'),
                        MetricChip(icon: Icons.favorite_outline, label: 'HRV', value: '78 ms'),
                        MetricChip(icon: Icons.show_chart, label: 'Load', value: 'Moderate'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _AdaptiveNav(strings: strings),
    );
  }
}

class _AdaptiveNav extends StatelessWidget {
  const _AdaptiveNav({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) Navigator.pushNamed(context, TrainPage.route);
        if (index == 2) Navigator.pushNamed(context, PlansPage.route);
        if (index == 3) Navigator.pushNamed(context, CommunityPage.route);
        if (index == 4) Navigator.pushNamed(context, ProfilePage.route);
      },
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: strings.t('home')),
        BottomNavigationBarItem(icon: const Icon(Icons.timer_outlined), label: strings.t('train')),
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: strings.t('plans')),
        BottomNavigationBarItem(icon: const Icon(Icons.groups_2_rounded), label: strings.t('community')),
        BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: strings.t('profile')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final int value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.primaryContainer.withOpacity(.35),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  '$value',
                  key: ValueKey<int>(value),
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard({required this.hydration, required this.strings});

  final double hydration;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.t('hydration'), style: theme.textTheme.titleMedium),
              Text(strings.t('hydrationReminder'), style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LinearProgressIndicator(
              value: hydration,
              minHeight: 16,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.4),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text('${strings.t('waterIntake')}: ${(hydration * 3.0).toStringAsFixed(1)} L'),
        ],
      ),
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.stat, required this.strings});

  final _LiveStat stat;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(.12),
            theme.colorScheme.secondary.withOpacity(.08),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _AnimatedMetric(label: strings.t('steps'), value: stat.steps),
          _AnimatedMetric(label: strings.t('calories'), value: stat.calories, suffix: ' kcal'),
          _AnimatedMetric(label: strings.t('progress'), value: (stat.steps / 100).clamp(0, 100).round(), suffix: '%'),
        ],
      ),
    );
  }
}

class _AnimatedMetric extends StatelessWidget {
  const _AnimatedMetric({required this.label, required this.value, this.suffix = ''});

  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: Text(
            '$value$suffix',
            key: ValueKey<int>(value),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected ? theme.colorScheme.primary.withOpacity(.15) : theme.colorScheme.surfaceVariant.withOpacity(.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.delay});

  final _UpcomingSession session;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 60, end: 0),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOut,
      delay: delay,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(.05),
                blurRadius: 24,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(.12),
              child: Text('${session.duration}'),
            ),
            title: Text(session.title, style: theme.textTheme.titleMedium),
            subtitle: Text(session.subtitle),
            trailing: Text(session.focus, style: theme.textTheme.labelMedium),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.primaryContainer.withOpacity(.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Flexible(child: Text(label, style: theme.textTheme.titleSmall)),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.controller, required this.label});

  final AnimationController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: theme.colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _HeroStory {
  const _HeroStory({required this.image, required this.title, required this.subtitle, required this.badge});

  final String image;
  final String title;
  final String subtitle;
  final String badge;

  static const minutesTag = 'min';
}

class _UpcomingSession {
  const _UpcomingSession({required this.title, required this.subtitle, required this.duration, required this.focus});

  final String title;
  final String subtitle;
  final int duration;
  final String focus;
}

class _LiveStat {
  const _LiveStat({required this.steps, required this.calories});

  final int steps;
  final int calories;
}
