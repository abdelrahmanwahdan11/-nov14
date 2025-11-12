import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/widgets/metric_chip.dart';
import '../../data/models/user_profile.dart';
import '../shared/app_state.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const route = '/profile';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: AnimatedBuilder(
        animation: state.profileController,
        builder: (context, _) {
          final profile = state.profileController.profile;
          final measurement = state.profileController.latestMeasurement;
          final theme = Theme.of(context);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                title: Text(strings.t('profile')), 
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(.16),
                          theme.colorScheme.primary.withOpacity(.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 96, left: 24, right: 24),
                    child: _ProfileHeader(
                      profile: profile,
                      measurement: measurement,
                      onEdit: () => _showEditSheet(context, state),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (profile.heightCm != null && profile.heightCm != 0)
                        MetricChip(
                          icon: Icons.height,
                          label: strings.t('height'),
                          value: '${profile.heightCm} cm',
                        ),
                      if (profile.weightKg != null && profile.weightKg != 0)
                        MetricChip(
                          icon: Icons.monitor_weight,
                          label: strings.t('weight'),
                          value: '${profile.weightKg!.toStringAsFixed(1)} kg',
                        ),
                      if (profile.age != null && profile.age != 0)
                        MetricChip(
                          icon: IconlyLight.calendar,
                          label: strings.t('age'),
                          value: '${profile.age}',
                        ),
                      if (profile.goal != null && profile.goal!.isNotEmpty)
                        MetricChip(
                          icon: Icons.flag_outlined,
                          label: strings.t('goal'),
                          value: profile.goal!,
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _BodyCompositionCard(
                        strings: strings,
                        measurement: measurement,
                        onAddMeasurement: () => _simulateMeasurement(state),
                      ),
                      const SizedBox(height: 20),
                      _SegmentalBalanceCard(strings: strings, measurement: measurement),
                      const SizedBox(height: 20),
                      _InbodyHistoryList(strings: strings, controller: state.profileController),
                      const SizedBox(height: 20),
                      _AccountSummaryCard(strings: strings, controller: state.profileController),
                      const SizedBox(height: 20),
                      _AccountSecurityCard(strings: strings, controller: state.profileController),
                      const SizedBox(height: 20),
                      _PersonalJournalCard(
                        strings: strings,
                        controller: state.profileController,
                        onAddEntry: () => _simulateJournalEntry(context, state),
                      ),
                      const SizedBox(height: 20),
                      _LoginHistoryCard(strings: strings, controller: state.profileController),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditSheet(context, state),
        icon: const Icon(Icons.edit),
        label: Text(strings.t('editProfile')),
      ),
    );
  }

  void _showEditSheet(BuildContext context, AppState state) {
    final strings = AppLocalizations.of(context);
    final profile = state.profileController.profile;
    final name = TextEditingController(text: profile.name);
    final email = TextEditingController(text: profile.email);
    final height = TextEditingController(text: (profile.heightCm ?? '').toString());
    final weight = TextEditingController(text: profile.weightKg?.toStringAsFixed(1) ?? '');
    final goal = TextEditingController(text: profile.goal ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.t('updateStats'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: strings.t('name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                decoration: InputDecoration(labelText: strings.t('email')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: height,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: strings.t('height')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: strings.t('weight')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: goal,
                decoration: InputDecoration(labelText: strings.t('goal')),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.t('cancel')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      state.profileController.updateProfile(
                        name: name.text,
                        email: email.text,
                        heightCm: int.tryParse(height.text),
                        weightKg: double.tryParse(weight.text),
                        goal: goal.text,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(strings.t('save')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateMeasurement(AppState state) {
    final last = state.profileController.latestMeasurement;
    final now = DateTime.now();
    final random = math.Random();
    final baselineWeight = last?.weightKg ?? state.profileController.profile.weightKg ?? 60;
    final measurement = InbodyMeasurement(
      date: now,
      weightKg: ((baselineWeight + (random.nextDouble() - 0.5))).clamp(45, 120).toDouble(),
      bodyFatPercentage: ((last?.bodyFatPercentage ?? 22) + (random.nextDouble() - 0.5)).clamp(5, 50).toDouble(),
      skeletalMuscleKg: ((last?.skeletalMuscleKg ?? 25) + (random.nextDouble() - 0.3)).clamp(10, 60).toDouble(),
      bodyWaterPercentage: ((last?.bodyWaterPercentage ?? 56) + (random.nextDouble() - 0.3)).clamp(30, 75).toDouble(),
      basalMetabolicRate: ((last?.basalMetabolicRate ?? 1350) + (random.nextDouble() * 30 - 15)).clamp(900, 2500).toDouble(),
      visceralFatLevel: ((last?.visceralFatLevel ?? 7) + (random.nextDouble() - 0.5)).clamp(1, 20).toDouble(),
      bmi: ((last?.bmi ?? 21.5) + (random.nextDouble() - 0.5)).clamp(14, 40).toDouble(),
    );
    state.profileController.recordMeasurement(measurement);
  }

  void _simulateJournalEntry(BuildContext context, AppState state) {
    final strings = AppLocalizations.of(context);
    final random = math.Random();
    const templates = ['strength', 'recovery', 'mobility', 'endurance'];
    final template = templates[random.nextInt(templates.length)];
    final tags = <String>{};
    switch (template) {
      case 'strength':
        tags.addAll(['strength', 'progress']);
        break;
      case 'recovery':
        tags.addAll(['recovery', 'hydration']);
        break;
      case 'mobility':
        tags.addAll(['mobility', 'focus']);
        break;
      default:
        tags.addAll(['endurance', 'cardio']);
        break;
    }
    final entry = ProfileJournalEntry(
      date: DateTime.now(),
      template: template,
      energyLevel: 3 + random.nextInt(3),
      effortLevel: 2 + random.nextInt(4),
      tags: tags.toList(),
    );
    state.profileController.addJournalEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.t('journalEntryAdded'))),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.measurement,
    required this.onEdit,
  });

  final UserProfile profile;
  final InbodyMeasurement? measurement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final localizations = MaterialLocalizations.of(context);
    final memberDate = localizations.formatMediumDate(profile.memberSince);
    final lastScan = measurement?.date ?? profile.lastInbodySync;
    final lastScanText = lastScan == null
        ? strings.t('noInbody')
        : '${strings.t('lastScan')}: ${localizations.formatMediumDate(lastScan)}';
    final trimmedName = profile.name.trim();
    final avatarInitial = trimmedName.isEmpty ? '?' : trimmedName.characters.first.toUpperCase();
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface.withOpacity(.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12),
              child: Text(avatarInitial),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(profile.email, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text('${strings.t('memberSince')}: $memberDate', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(lastScanText, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyCompositionCard extends StatelessWidget {
  const _BodyCompositionCard({
    required this.strings,
    required this.measurement,
    required this.onAddMeasurement,
  });

  final AppLocalizations strings;
  final InbodyMeasurement? measurement;
  final VoidCallback onAddMeasurement;

  @override
  Widget build(BuildContext context) {
    final leanMass = measurement == null
        ? 0.0
        : (measurement!.weightKg * (1 - measurement!.bodyFatPercentage / 100)).clamp(0, 200);
    final fatMass = measurement == null
        ? 0.0
        : (measurement!.weightKg - leanMass).clamp(0, measurement!.weightKg);
    final metabolicAge = measurement == null
        ? 0
        : ((measurement!.basalMetabolicRate / 10).clamp(18, 65)).round();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
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
                      Text(strings.t('bodyComposition'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(strings.t('bodyCompositionSubtitle'), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAddMeasurement,
                  icon: const Icon(Icons.add_chart),
                  tooltip: strings.t('addScan'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: measurement == null
                  ? Text(strings.t('noInbody'), style: Theme.of(context).textTheme.bodyMedium)
                  : GridView.count(
                      key: ValueKey(measurement.date),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 720
                          ? 4
                          : MediaQuery.of(context).size.width > 480
                              ? 3
                              : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        _InbodyMetricTile(
                          label: strings.t('weight'),
                          value: '${measurement.weightKg.toStringAsFixed(1)} kg',
                          icon: Icons.monitor_weight,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('bodyFat'),
                          value: '${measurement.bodyFatPercentage.toStringAsFixed(1)} %',
                          icon: Icons.percent,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('muscleMass'),
                          value: '${measurement.skeletalMuscleKg.toStringAsFixed(1)} kg',
                          icon: Icons.fitness_center,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('bodyWater'),
                          value: '${measurement.bodyWaterPercentage.toStringAsFixed(1)} %',
                          icon: Icons.water_drop_outlined,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('bmr'),
                          value: '${measurement.basalMetabolicRate.toStringAsFixed(0)} kcal',
                          icon: Icons.local_fire_department_outlined,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('visceralFat'),
                          value: measurement.visceralFatLevel.toStringAsFixed(1),
                          icon: Icons.security_outlined,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('bmi'),
                          value: measurement.bmi.toStringAsFixed(1),
                          icon: Icons.leaderboard,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('leanMass'),
                          value: '${leanMass.toStringAsFixed(1)} kg',
                          icon: Icons.directions_run,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('fatMass'),
                          value: '${fatMass.toStringAsFixed(1)} kg',
                          icon: Icons.incomplete_circle,
                        ),
                        _InbodyMetricTile(
                          label: strings.t('metabolicAge'),
                          value: '$metabolicAge',
                          icon: Icons.speed,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentalBalanceCard extends StatelessWidget {
  const _SegmentalBalanceCard({required this.strings, required this.measurement});

  final AppLocalizations strings;
  final InbodyMeasurement? measurement;

  @override
  Widget build(BuildContext context) {
    final segments = measurement == null ? <_SegmentSnapshot>[] : _buildSegments(measurement!);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('segmentalBalance'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(strings.t('segmentalBalanceSubtitle'), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            if (segments.isEmpty)
              Text(strings.t('noInbody'), style: Theme.of(context).textTheme.bodyMedium)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: segments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final segment = segments[index];
                  return _SegmentRow(segment: segment, strings: strings);
                },
              ),
          ],
        ),
      ),
    );
  }

  List<_SegmentSnapshot> _buildSegments(InbodyMeasurement measurement) {
    final totalMuscle = measurement.skeletalMuscleKg.clamp(1, 200);
    final totalFat = (measurement.weightKg * measurement.bodyFatPercentage / 100).clamp(1, 200);
    final upperMuscle = (totalMuscle * 0.34).clamp(0, totalMuscle);
    final lowerMuscle = (totalMuscle * 0.44).clamp(0, totalMuscle);
    final coreMuscle = (totalMuscle * 0.22).clamp(0, totalMuscle);
    final upperFat = (totalFat * 0.32).clamp(0, totalFat);
    final lowerFat = (totalFat * 0.38).clamp(0, totalFat);
    final coreFat = (totalFat * 0.30).clamp(0, totalFat);
    final leftMuscle = (totalMuscle * 0.49).clamp(0, totalMuscle);
    final rightMuscle = (totalMuscle * 0.51).clamp(0, totalMuscle);
    final leftFat = (totalFat * 0.5).clamp(0, totalFat);
    final rightFat = (totalFat * 0.5).clamp(0, totalFat);
    final symmetryDelta = ((rightMuscle - leftMuscle) / totalMuscle * 100).clamp(-25, 25);
    return [
      _SegmentSnapshot(
        label: strings.t('upperBody'),
        musclePercent: upperMuscle / totalMuscle * 100,
        fatPercent: upperFat / totalFat * 100,
      ),
      _SegmentSnapshot(
        label: strings.t('lowerBody'),
        musclePercent: lowerMuscle / totalMuscle * 100,
        fatPercent: lowerFat / totalFat * 100,
      ),
      _SegmentSnapshot(
        label: strings.t('core'),
        musclePercent: coreMuscle / totalMuscle * 100,
        fatPercent: coreFat / totalFat * 100,
      ),
      _SegmentSnapshot(
        label: strings.t('leftSide'),
        musclePercent: leftMuscle / totalMuscle * 100,
        fatPercent: leftFat / totalFat * 100,
        deltaPercent: symmetryDelta,
      ),
      _SegmentSnapshot(
        label: strings.t('rightSide'),
        musclePercent: rightMuscle / totalMuscle * 100,
        fatPercent: rightFat / totalFat * 100,
      ),
    ];
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({required this.segment, required this.strings});

  final _SegmentSnapshot segment;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceVariant.withOpacity(.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(segment.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutQuart,
            tween: Tween(begin: 0, end: segment.musclePercent.clamp(0, 100)),
            builder: (context, value, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings.t('muscleMass'), style: theme.textTheme.labelMedium),
                      Text('${value.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutQuart,
            tween: Tween(begin: 0, end: segment.fatPercent.clamp(0, 100)),
            builder: (context, value, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings.t('bodyFat'), style: theme.textTheme.labelMedium),
                      Text('${value.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 6,
                    color: theme.colorScheme.tertiary,
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              );
            },
          ),
          if (segment.deltaPercent != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.compare_arrows, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${segment.deltaPercent! >= 0 ? '+' : ''}${segment.deltaPercent!.toStringAsFixed(1)}% ${strings.t('balanceDelta')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentSnapshot {
  const _SegmentSnapshot({
    required this.label,
    required this.musclePercent,
    required this.fatPercent,
    this.deltaPercent,
  });

  final String label;
  final double musclePercent;
  final double fatPercent;
  final double? deltaPercent;
}

class _AccountSecurityCard extends StatelessWidget {
  const _AccountSecurityCard({required this.strings, required this.controller});

  final AppLocalizations strings;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final lastLogin = controller.lastLogin;
    final methodCounts = controller.loginBreakdownByMethod;
    final devices = controller.activeDevices;
    final totalLogins = controller.loginHistory.length;
    final primaryDevice = controller.loginHistory.isEmpty ? strings.t('notAvailable') : controller.loginHistory.first.device;
    final lastActiveText = lastLogin == null
        ? strings.t('noLogins')
        : '${localizations.formatMediumDate(lastLogin)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(lastLogin))}';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('accountSecurity'), style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(strings.t('accountSecuritySubtitle'), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(.12),
                child: Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
              ),
              title: Text('${strings.t('totalLogins')}: $totalLogins'),
              subtitle: Text('${strings.t('lastActive')}: $lastActiveText'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(.6),
                child: Icon(Icons.devices_other, color: theme.colorScheme.onSecondaryContainer),
              ),
              title: Text('${strings.t('primaryDevice')}: $primaryDevice'),
              subtitle: Text('${strings.t('activeDevices')}: ${devices.isEmpty ? strings.t('notAvailable') : devices.length}'),
            ),
            const SizedBox(height: 12),
            Text(strings.t('loginMethods'), style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: methodCounts.entries
                  .map(
                    (entry) => Chip(
                      avatar: Icon(_methodIcon(entry.key), size: 18),
                      label: Text('${_methodLabel(entry.key, strings)} • ${entry.value}'),
                    ),
                  )
                  .toList(),
            ),
            if (devices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(strings.t('activeDevices'), style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: devices
                    .map(
                      (device) => Chip(
                        avatar: const Icon(Icons.device_hub, size: 18),
                        label: Text(device),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'guest':
        return Icons.person_outline;
      case 'register':
        return Icons.person_add_alt;
      default:
        return Icons.lock_outline;
    }
  }

  String _methodLabel(String method, AppLocalizations strings) {
    switch (method) {
      case 'guest':
        return strings.t('loginMethodGuest');
      case 'register':
        return strings.t('loginMethodRegister');
      default:
        return strings.t('loginMethodPassword');
    }
  }
}

class _PersonalJournalCard extends StatelessWidget {
  const _PersonalJournalCard({
    required this.strings,
    required this.controller,
    required this.onAddEntry,
  });

  final AppLocalizations strings;
  final ProfileController controller;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = controller.journalEntries;
    final localizations = MaterialLocalizations.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
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
                      Text(strings.t('personalJournal'), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(strings.t('journalSubtitle'), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddEntry,
                  icon: const Icon(Icons.add_task),
                  label: Text(strings.t('addJournalEntry')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Text(strings.t('journalEmpty'), style: theme.textTheme.bodyMedium)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final title = _journalTitle(strings, entry.template);
                  final body = _journalBody(strings, entry.template);
                  final date = localizations.formatMediumDate(entry.date);
                  final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(entry.date));
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 320 + index * 40),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: theme.colorScheme.surfaceVariant.withOpacity(.6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$date · $time', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 8),
                          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(body, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.bolt, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text('${strings.t('energy')}: ${entry.energyLevel}/5', style: theme.textTheme.labelMedium),
                              const SizedBox(width: 16),
                              Icon(Icons.show_chart, size: 18, color: theme.colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text('${strings.t('effort')}: ${entry.effortLevel}/5', style: theme.textTheme.labelMedium),
                              if (entry.synced) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.cloud_done, size: 18, color: theme.colorScheme.tertiary),
                                const SizedBox(width: 6),
                                Text(strings.t('synced'), style: theme.textTheme.labelMedium),
                              ],
                            ],
                          ),
                          if (entry.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(strings.t(tag)),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _journalTitle(AppLocalizations strings, String template) {
    switch (template) {
      case 'strength':
        return strings.t('journalStrengthTitle');
      case 'recovery':
        return strings.t('journalRecoveryTitle');
      case 'mobility':
        return strings.t('journalMobilityTitle');
      default:
        return strings.t('journalEnduranceTitle');
    }
  }

  String _journalBody(AppLocalizations strings, String template) {
    switch (template) {
      case 'strength':
        return strings.t('journalStrengthBody');
      case 'recovery':
        return strings.t('journalRecoveryBody');
      case 'mobility':
        return strings.t('journalMobilityBody');
      default:
        return strings.t('journalEnduranceBody');
    }
  }
}

class _InbodyHistoryList extends StatelessWidget {
  const _InbodyHistoryList({required this.strings, required this.controller});

  final AppLocalizations strings;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final history = controller.inbodyHistory;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('inbodyHistory'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = history[index];
                final dateText = localizations.formatMediumDate(item.date);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
                    child: const Icon(Icons.insights_outlined),
                  ),
                  title: Text('${item.weightKg.toStringAsFixed(1)} kg • ${item.bodyFatPercentage.toStringAsFixed(1)}% BF'),
                  subtitle: Text('${strings.t('muscleMass')}: ${item.skeletalMuscleKg.toStringAsFixed(1)} kg  ·  $dateText'),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: history.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({required this.strings, required this.controller});

  final AppLocalizations strings;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    final localizations = MaterialLocalizations.of(context);
    final lastLogin = controller.loginHistory.isEmpty ? null : controller.loginHistory.first;
    final lastLoginTime = lastLogin == null
        ? strings.t('noLogins')
        : '${localizations.formatMediumDate(lastLogin.timestamp)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(lastLogin.timestamp))}';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('accountSummary'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(IconlyLight.profile),
              title: Text(profile.email),
              subtitle: Text(strings.t('accountEmail')), 
            ),
            ListTile(
              leading: const Icon(IconlyLight.time_circle),
              title: Text('${strings.t('memberSince')}: ${localizations.formatMediumDate(profile.memberSince)}'),
              subtitle: Text('${strings.t('lastLogin')}: $lastLoginTime'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHistoryCard extends StatelessWidget {
  const _LoginHistoryCard({required this.strings, required this.controller});

  final AppLocalizations strings;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final history = controller.loginHistory;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('loginHistory'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Text(strings.t('noLogins'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = history[index];
                  final date = localizations.formatMediumDate(item.timestamp);
                  final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(item.timestamp));
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Icon(_methodIcon(item.method), color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(_methodLabel(item.method, strings)),
                    subtitle: Text('${item.device} · $date · $time'),
                    trailing: Icon(item.successful ? Icons.check_circle : Icons.error_outline,
                        color: item.successful
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: history.length,
              ),
          ],
        ),
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'guest':
        return Icons.person_outline;
      case 'register':
        return Icons.person_add_alt;
      default:
        return Icons.lock_outline;
    }
  }

  String _methodLabel(String method, AppLocalizations strings) {
    switch (method) {
      case 'guest':
        return strings.t('loginMethodGuest');
      case 'register':
        return strings.t('loginMethodRegister');
      default:
        return strings.t('loginMethodPassword');
    }
  }
}

class _InbodyMetricTile extends StatelessWidget {
  const _InbodyMetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
