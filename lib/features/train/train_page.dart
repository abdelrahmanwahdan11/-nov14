import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/localization.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  static const route = '/train';

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> with TickerProviderStateMixin {
  final PageController _modeController = PageController(viewportFraction: 0.82);
  final StreamController<_TrainMetric> _metricController = StreamController<_TrainMetric>.broadcast();
  final List<_Interval> _intervals = const [
    _Interval(type: _IntervalType.work, duration: Duration(minutes: 1, seconds: 30)),
    _Interval(type: _IntervalType.rest, duration: Duration(seconds: 30)),
    _Interval(type: _IntervalType.work, duration: Duration(minutes: 1, seconds: 45)),
    _Interval(type: _IntervalType.rest, duration: Duration(seconds: 30)),
    _Interval(type: _IntervalType.work, duration: Duration(minutes: 2)),
    _Interval(type: _IntervalType.rest, duration: Duration(minutes: 1)),
  ];
  final List<_TrainMode> _modes = const [
    _TrainMode(title: 'Run', subtitle: 'Endurance build', color: Color(0xFF0EA5E9), icon: Icons.directions_run, intensity: 1.0),
    _TrainMode(title: 'HIIT', subtitle: 'Explosive sets', color: Color(0xFFF97316), icon: Icons.fitness_center, intensity: 1.35),
    _TrainMode(title: 'Cycling', subtitle: 'Cadence focus', color: Color(0xFF22C55E), icon: Icons.directions_bike, intensity: 0.9),
    _TrainMode(title: 'Strength', subtitle: 'Power blocks', color: Color(0xFF8B5CF6), icon: Icons.electric_bolt, intensity: 1.15),
  ];

  int _modeIndex = 0;
  Duration _elapsed = Duration.zero;
  bool _running = true;
  Timer? _timer;
  _TrainMetric _latest = const _TrainMetric(distance: 0, pace: '--', steps: 0, heart: 0, calories: 0);

  @override
  void initState() {
    super.initState();
    _metricController.add(_latest);
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_running) return;
      setState(() => _elapsed += const Duration(seconds: 1));
      _emitMetric();
    });
  }

  void _emitMetric() {
    final metric = _computeMetric(_elapsed, _modes[_modeIndex]);
    _latest = metric;
    _metricController.add(metric);
  }

  _TrainMetric _computeMetric(Duration elapsed, _TrainMode mode) {
    final seconds = elapsed.inSeconds;
    final distanceKm = seconds * (mode.intensity * 0.0025);
    final paceSeconds = distanceKm <= 0 ? 0 : (seconds / distanceKm).round();
    final paceMinutes = paceSeconds ~/ 60;
    final paceRemainder = paceSeconds % 60;
    final steps = (seconds * (90 + mode.intensity * 40) / 60).round();
    final heart = (112 + mode.intensity * 38 + math.sin(seconds / 4) * 9).round();
    final calories = (120 + seconds * mode.intensity * 0.12).round();
    final pace = distanceKm <= 0 ? '--' : '${paceMinutes.toString().padLeft(2, '0')}:${paceRemainder.toString().padLeft(2, '0')}';
    return _TrainMetric(
      distance: distanceKm,
      pace: pace,
      steps: steps,
      heart: heart,
      calories: calories,
    );
  }

  int get _cycleSeconds => _intervals.fold<int>(0, (value, interval) => value + interval.duration.inSeconds);

  int _currentIntervalIndex() {
    if (_elapsed == Duration.zero) return 0;
    final total = _elapsed.inSeconds % _cycleSeconds;
    int cumulative = 0;
    for (var i = 0; i < _intervals.length; i++) {
      cumulative += _intervals[i].duration.inSeconds;
      if (total < cumulative) return i;
    }
    return _intervals.length - 1;
  }

  double _intervalProgress(int index) {
    final total = _elapsed.inSeconds % _cycleSeconds;
    int start = 0;
    for (var i = 0; i < index; i++) {
      start += _intervals[i].duration.inSeconds;
    }
    final end = start + _intervals[index].duration.inSeconds;
    if (total >= end) return 1;
    if (total <= start) return 0;
    return (total - start) / (end - start);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _modeController.dispose();
    _metricController.close();
    super.dispose();
  }

  void _toggleRun() {
    setState(() => _running = !_running);
  }

  Future<void> _endSession() async {
    setState(() => _running = false);
    await _showSummary();
  }

  Future<void> _showSummary() {
    final strings = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(strings.t('sessionSummary'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _SummaryRow(label: strings.t('totalTime'), value: _formatElapsed(_elapsed)),
              _SummaryRow(label: strings.t('distance'), value: '${_latest.distance.toStringAsFixed(2)} km'),
              _SummaryRow(label: strings.t('avgPace'), value: _latest.pace),
              _SummaryRow(label: strings.t('calories'), value: '${_latest.calories} kcal'),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(strings.t('close')),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _formatElapsed(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mode = _modes[_modeIndex];
    final intervalIndex = _currentIntervalIndex();
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('train'))),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mode.color.withOpacity(.22), theme.scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _modeController,
                  onPageChanged: (value) {
                    setState(() => _modeIndex = value);
                    _emitMetric();
                  },
                  itemCount: _modes.length,
                  itemBuilder: (context, index) {
                    final current = _modes[index];
                    final active = index == _modeIndex;
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 320),
                      scale: active ? 1 : 0.95,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 320),
                        opacity: active ? 1 : 0.55,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: theme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: mode.color.withOpacity(.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(current.icon, color: current.color, size: 28),
                                  const SizedBox(height: 12),
                                  Text(current.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text(current.subtitle, style: theme.textTheme.bodyMedium),
                                  const Spacer(),
                                  LinearProgressIndicator(value: active ? 0.7 : 0.3, minHeight: 6),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(_formatElapsed(_elapsed), style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              StreamBuilder<_TrainMetric>(
                stream: _metricController.stream,
                initialData: _latest,
                builder: (context, snapshot) {
                  final metric = snapshot.data ?? _latest;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _MetricTile(label: strings.t('distance'), value: '${metric.distance.toStringAsFixed(2)} km'),
                        _MetricTile(label: strings.t('pace'), value: metric.pace),
                        _MetricTile(label: strings.t('steps'), value: '${metric.steps}'),
                        _MetricTile(label: strings.t('heartRate'), value: '${metric.heart} bpm'),
                        _MetricTile(label: strings.t('calories'), value: '${metric.calories} kcal'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      itemCount: _intervals.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(strings.t('intervals'), style: theme.textTheme.titleMedium),
                          );
                        }
                        final interval = _intervals[index - 1];
                        final active = index - 1 == intervalIndex;
                        final progress = active ? _intervalProgress(index - 1) : (index - 1 < intervalIndex ? 1 : 0);
                        return _IntervalTile(
                          interval: interval,
                          strings: strings,
                          active: active,
                          progress: progress,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleRun,
                        child: Text(_running ? strings.t('pause') : strings.t('resume')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _endSession,
                        child: Text(strings.t('endSession')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalTile extends StatelessWidget {
  const _IntervalTile({
    required this.interval,
    required this.strings,
    required this.active,
    required this.progress,
  });

  final _Interval interval;
  final AppLocalizations strings;
  final bool active;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = interval.type == _IntervalType.work ? strings.t('intervalWork') : strings.t('intervalRest');
    final duration = interval.duration;
    final formatted = '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: active ? theme.colorScheme.primary.withOpacity(.15) : theme.colorScheme.surfaceVariant.withOpacity(.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(formatted, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TrainMode {
  const _TrainMode({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.intensity,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double intensity;
}

class _Interval {
  const _Interval({required this.type, required this.duration});

  final _IntervalType type;
  final Duration duration;
}

enum _IntervalType { work, rest }

class _TrainMetric {
  const _TrainMetric({
    required this.distance,
    required this.pace,
    required this.steps,
    required this.heart,
    required this.calories,
  });

  final double distance;
  final String pace;
  final int steps;
  final int heart;
  final int calories;
}
