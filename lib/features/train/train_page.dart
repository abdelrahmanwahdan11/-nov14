import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/localization.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  static const route = '/train';

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  late final StreamController<Duration> _timerStream;
  Duration _elapsed = Duration.zero;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _timerStream = StreamController.broadcast();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_running) return;
      _elapsed += const Duration(seconds: 1);
      _timerStream.add(_elapsed);
    });
  }

  @override
  void dispose() {
    _timerStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('train'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: const [true, false, false, false],
              onPressed: (_) {},
              borderRadius: BorderRadius.circular(18),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Run')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('HIIT')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Cycling')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Strength')),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<Duration>(
              stream: _timerStream.stream,
              initialData: _elapsed,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
                final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
                return Text('$minutes:$seconds', style: Theme.of(context).textTheme.displayMedium);
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: const [
                _HudMetric(label: 'Distance', value: '2.4 km'),
                _HudMetric(label: 'Pace', value: '5:20'),
                _HudMetric(label: 'Steps', value: '3560'),
                _HudMetric(label: 'HR', value: '142 bpm'),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => setState(() => _running = !_running), child: Text(_running ? 'Pause' : 'Resume')),
                ElevatedButton(onPressed: () {}, child: const Text('End')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
