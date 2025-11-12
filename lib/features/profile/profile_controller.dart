import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required SharedPreferences prefs})
      : _prefs = prefs,
        _profile = UserProfile(
          name: prefs.getString('user_displayName') ?? 'Layla Haddad',
          email: prefs.getString('user_email') ?? 'layla.haddad@example.com',
          memberSince: _restoreDate(prefs.getInt('user_memberSince')) ?? DateTime(2022, 2, 12),
          age: _readOptionalInt(prefs, 'user_age') ?? 28,
          gender: _readOptionalString(prefs, 'user_gender') ?? 'F',
          heightCm: _readOptionalInt(prefs, 'user_heightCm') ?? 168,
          weightKg: _readOptionalDouble(prefs, 'user_weightKg') ?? 62.4,
          goal: _readOptionalString(prefs, 'user_goal') ?? 'Feel powerful and agile every week.',
          lastInbodySync: _restoreDate(prefs.getInt('user_lastInbodyEpoch')),
          restingHeartRate: _readOptionalInt(prefs, 'user_restingHeartRate') ?? 52,
          vo2Max: _readOptionalDouble(prefs, 'user_vo2Max') ?? 43.2,
          sleepGoalHours: _readOptionalDouble(prefs, 'user_sleepGoalHours') ?? 7.5,
          hydrationGoalLiters: _readOptionalDouble(prefs, 'user_hydrationGoalLiters') ?? 2.7,
          bodyAge: _readOptionalDouble(prefs, 'user_bodyAge') ?? 26,
          focusArea: _readOptionalString(prefs, 'user_focusArea') ?? 'Power & Mobility',
        ),
        _inbodyHistory = _seedInbodyHistory(prefs.getStringList('user_inbody_history')),
        _loginHistory = _seedLoginHistory(prefs.getStringList('user_login_history')),
        _journalEntries = _seedJournalEntries(prefs.getStringList('user_journal_entries')),
        _readiness = _seedReadinessHistory(prefs.getStringList('user_readiness_history')),
        _hydrationLogs = _seedHydrationLogs(prefs.getStringList('user_hydration_logs')),
        _performanceTrends =
            _seedPerformanceTrends(prefs.getStringList('user_performance_trends')),
        _milestones =
            _seedPerformanceMilestones(prefs.getStringList('user_performance_milestones')),
        _macroTargets = _seedMacroTargets(prefs),
        _nutritionLogs = _seedNutritionLogs(prefs.getStringList('user_nutrition_logs')),
        _sleepRecords = _seedSleepRecords(prefs.getStringList('user_sleep_records')),
        _mindfulnessSessions =
            _seedMindfulnessSessions(prefs.getStringList('user_mindfulness_sessions')),
        _recoveryRoutines =
            _seedRecoveryRoutines(prefs.getStringList('user_recovery_routines'));

  final SharedPreferences _prefs;
  UserProfile _profile;
  final List<InbodyMeasurement> _inbodyHistory;
  final List<LoginRecord> _loginHistory;
  final List<ProfileJournalEntry> _journalEntries;
  final List<ReadinessSnapshot> _readiness;
  final List<HydrationLog> _hydrationLogs;
  final List<PerformanceTrend> _performanceTrends;
  final List<PerformanceMilestone> _milestones;
  MacroTargets _macroTargets;
  final List<NutritionLog> _nutritionLogs;
  final List<SleepRecord> _sleepRecords;
  final List<MindfulnessSession> _mindfulnessSessions;
  final List<RecoveryRoutine> _recoveryRoutines;

  UserProfile get profile => _profile;
  List<InbodyMeasurement> get inbodyHistory => List.unmodifiable(_inbodyHistory);
  List<LoginRecord> get loginHistory => List.unmodifiable(_loginHistory);
  List<ProfileJournalEntry> get journalEntries => List.unmodifiable(_journalEntries);
  List<ReadinessSnapshot> get readinessHistory => List.unmodifiable(_readiness);
  List<HydrationLog> get hydrationLogs => List.unmodifiable(_hydrationLogs);
  List<PerformanceTrend> get performanceTrends => List.unmodifiable(_performanceTrends);
  List<PerformanceMilestone> get performanceMilestones => List.unmodifiable(_milestones);
  MacroTargets get macroTargets => _macroTargets;
  List<NutritionLog> get nutritionLogs => List.unmodifiable(_nutritionLogs);
  List<SleepRecord> get sleepRecords => List.unmodifiable(_sleepRecords);
  List<MindfulnessSession> get mindfulnessSessions =>
      List.unmodifiable(_mindfulnessSessions);
  List<RecoveryRoutine> get recoveryRoutines => List.unmodifiable(_recoveryRoutines);

  NutritionLog? get latestMeal => _nutritionLogs.isEmpty ? null : _nutritionLogs.first;
  SleepRecord? get latestSleep => _sleepRecords.isEmpty ? null : _sleepRecords.first;
  MindfulnessSession? get latestMindfulness =>
      _mindfulnessSessions.isEmpty ? null : _mindfulnessSessions.first;
  RecoveryRoutine? get nextRecoveryRoutine {
    if (_recoveryRoutines.isEmpty) return null;
    final sorted = [..._recoveryRoutines];
    sorted.sort((a, b) {
      final aDate = a.scheduledFor ?? a.lastCompleted ?? DateTime.now();
      final bDate = b.scheduledFor ?? b.lastCompleted ?? DateTime.now();
      return aDate.compareTo(bDate);
    });
    return sorted.first;
  }

  double get calorieProgressToday {
    if (_macroTargets.calories <= 0) return 0;
    final today = DateTime.now();
    final total = _nutritionLogs
        .where((log) => _isSameDay(log.timestamp, today))
        .fold<int>(0, (sum, log) => sum + log.calories);
    return (total / _macroTargets.calories).clamp(0, 1.0);
  }

  Map<String, double> get macroProgressToday {
    final today = DateTime.now();
    final totals = _nutritionLogs
        .where((log) => _isSameDay(log.timestamp, today))
        .fold<Map<String, int>>(
          {'protein': 0, 'carbs': 0, 'fats': 0},
          (map, log) {
            map.update('protein', (value) => value + log.protein);
            map.update('carbs', (value) => value + log.carbs);
            map.update('fats', (value) => value + log.fats);
            return map;
          },
        );
    return {
      'protein': _macroTargets.protein == 0
          ? 0
          : (totals['protein']! / _macroTargets.protein).clamp(0, 1.0),
      'carbs': _macroTargets.carbs == 0
          ? 0
          : (totals['carbs']! / _macroTargets.carbs).clamp(0, 1.0),
      'fats': _macroTargets.fats == 0
          ? 0
          : (totals['fats']! / _macroTargets.fats).clamp(0, 1.0),
    };
  }

  double get sleepConsistencyScore {
    if (_sleepRecords.length < 2) return 1;
    final averageHours =
        _sleepRecords.fold<double>(0, (sum, record) => sum + record.hours) /
            _sleepRecords.length;
    final variability = _sleepRecords.fold<double>(
          0,
          (sum, record) => sum + (record.hours - averageHours).abs(),
        ) /
        _sleepRecords.length;
    final normalized = (1 - variability / 3).clamp(0, 1.0);
    return double.parse(normalized.toStringAsFixed(2));
  }

  double get mindfulnessMinutesWeek {
    final now = DateTime.now();
    final minutes = _mindfulnessSessions
        .where((session) => now.difference(session.date).inDays < 7)
        .fold<int>(0, (sum, session) => sum + session.durationMinutes);
    return minutes.toDouble();
  }

  int get bestRecoveryStreak {
    if (_recoveryRoutines.isEmpty) return 0;
    return _recoveryRoutines.fold<int>(
        0, (best, routine) => routine.streak > best ? routine.streak : best);
  }

  PerformanceTrend? get topMomentum {
    if (_performanceTrends.isEmpty) return null;
    return _performanceTrends.reduce(
      (best, trend) => trend.weekChange > best.weekChange ? trend : best,
    );
  }

  PerformanceTrend? get laggingTrend {
    if (_performanceTrends.isEmpty) return null;
    return _performanceTrends.reduce(
      (worst, trend) => trend.weekChange < worst.weekChange ? trend : worst,
    );
  }

  double get overallPerformanceScore {
    if (_performanceTrends.isEmpty) return 0;
    final sum = _performanceTrends.fold<double>(
      0,
      (value, trend) => value + (trend.points.isEmpty ? 0 : trend.points.first.value),
    );
    return double.parse((sum / _performanceTrends.length).toStringAsFixed(1));
  }

  double get momentumScore {
    if (_performanceTrends.isEmpty) return 0;
    final sum = _performanceTrends.fold<double>(0, (value, trend) => value + trend.weekChange);
    return double.parse((sum / _performanceTrends.length).toStringAsFixed(1));
  }

  String get recommendedFocusKey {
    final lagging = laggingTrend;
    if (lagging == null) {
      return 'mobility';
    }
    return lagging.metric;
  }

  InbodyMeasurement? get latestMeasurement => _inbodyHistory.isEmpty ? null : _inbodyHistory.first;
  ProfileJournalEntry? get latestJournal => _journalEntries.isEmpty ? null : _journalEntries.first;
  DateTime? get lastLogin => _loginHistory.isEmpty ? null : _loginHistory.first.timestamp;
  ReadinessSnapshot? get latestReadiness => _readiness.isEmpty ? null : _readiness.first;

  Map<String, int> get loginBreakdownByMethod {
    final map = <String, int>{};
    for (final record in _loginHistory) {
      map.update(record.method, (value) => value + 1, ifAbsent: () => 1);
    }
    return map;
  }

  List<String> get activeDevices {
    final devices = <String>{};
    for (final record in _loginHistory) {
      devices.add(record.device);
    }
    return devices.toList()..sort();
  }

  void updateProfile({
    String? name,
    String? email,
    int? age,
    String? gender,
    int? heightCm,
    double? weightKg,
    String? goal,
  }) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      goal: goal,
      restingHeartRate: restingHeartRate,
      vo2Max: vo2Max,
      sleepGoalHours: sleepGoalHours,
      hydrationGoalLiters: hydrationGoalLiters,
      bodyAge: bodyAge,
      focusArea: focusArea,
    );
    _persistProfile();
    notifyListeners();
  }

  void recordMeasurement(InbodyMeasurement measurement) {
    _inbodyHistory.insert(0, measurement);
    if (_inbodyHistory.length > 12) {
      _inbodyHistory.removeLast();
    }
    _profile = _profile.copyWith(lastInbodySync: measurement.date, weightKg: measurement.weightKg);
    _persistProfile();
    _persistInbody();
    notifyListeners();
  }

  void recordLogin({required String method, required String device, bool successful = true}) {
    _loginHistory.insert(0, LoginRecord(
      timestamp: DateTime.now(),
      method: method,
      device: device,
      successful: successful,
    ));
    if (_loginHistory.length > 20) {
      _loginHistory.removeLast();
    }
    _persistLogins();
    notifyListeners();
  }

  void completeRegistration({required String name, required String email}) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      memberSince: DateTime.now(),
    );
    _persistProfile();
    notifyListeners();
  }

  void addJournalEntry(ProfileJournalEntry entry) {
    _journalEntries.insert(0, entry);
    if (_journalEntries.length > 20) {
      _journalEntries.removeLast();
    }
    _persistJournal();
    notifyListeners();
  }

  void recordReadiness(ReadinessSnapshot snapshot) {
    _readiness.insert(0, snapshot);
    if (_readiness.length > 14) {
      _readiness.removeLast();
    }
    _persistReadiness();
    notifyListeners();
  }

  void logHydration(double liters) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final index = _hydrationLogs.indexWhere(
      (log) => _isSameDay(log.date, today),
    );
    if (index >= 0) {
      final updated = _hydrationLogs[index]
          .copyWith(liters: (_hydrationLogs[index].liters + liters).clamp(0, 10));
      _hydrationLogs[index] = updated;
      if (index != 0) {
        _hydrationLogs
          ..removeAt(index)
          ..insert(0, updated);
      }
    } else {
      _hydrationLogs.insert(0, HydrationLog(date: today, liters: liters));
    }
    if (_hydrationLogs.length > 14) {
      _hydrationLogs.removeLast();
    }
    _persistHydration();
    notifyListeners();
  }

  void addTrainingSample({required String metric, required double score}) {
    final index = _performanceTrends.indexWhere((trend) => trend.metric == metric);
    if (index == -1) return;
    final sanitizedScore = double.parse(score.toStringAsFixed(1));
    final today = TrendPoint(date: DateTime.now(), value: sanitizedScore);
    final combined = [today, ..._performanceTrends[index].points];
    combined.sort((a, b) => b.date.compareTo(a.date));
    final truncated = combined.take(14).toList();
    final latest = truncated.first.value;
    final previous = truncated.length > 1 ? truncated[1].value : latest;
    final monthBaseline = truncated.length > 7 ? truncated[7].value : truncated.last.value;
    final updated = _performanceTrends[index].copyWith(
      points: truncated,
      weekChange: double.parse((latest - previous).toStringAsFixed(1)),
      monthChange: double.parse((latest - monthBaseline).toStringAsFixed(1)),
      lastUpdated: DateTime.now(),
    );
    _performanceTrends[index] = updated;
    _persistPerformanceTrends();
    notifyListeners();
    if (sanitizedScore >= 92) {
      completeNextMilestone();
    }
  }

  void completeMilestone(String id) {
    final index = _milestones.indexWhere((milestone) => milestone.id == id);
    if (index == -1) return;
    if (_milestones[index].achieved) return;
    _milestones[index] = _milestones[index].copyWith(
      achieved: true,
      achievedOn: DateTime.now(),
    );
    _persistPerformanceMilestones();
    notifyListeners();
  }

  void completeNextMilestone() {
    final index = _milestones.indexWhere((milestone) => !milestone.achieved);
    if (index == -1) return;
    _milestones[index] = _milestones[index].copyWith(
      achieved: true,
      achievedOn: DateTime.now(),
    );
    _persistPerformanceMilestones();
    notifyListeners();
  }

  double get hydrationToday {
    if (_hydrationLogs.isEmpty) return 0;
    final today = DateTime.now();
    final total = _hydrationLogs
        .where((log) => _isSameDay(log.date, today))
        .fold<double>(0, (sum, log) => sum + log.liters);
    return double.parse(total.toStringAsFixed(2));
  }

  double get hydrationGoal => _profile.hydrationGoalLiters ?? 2.7;

  double get hydrationProgress {
    if (hydrationGoal == 0) return 0;
    final progress = hydrationToday / hydrationGoal;
    return progress.clamp(0, 1.0);
  }

  double get averageSleepHours {
    if (_readiness.isEmpty) {
      return _profile.sleepGoalHours ?? 0;
    }
    final avg =
        _readiness.fold<double>(0, (sum, entry) => sum + entry.sleepHours) / _readiness.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  int get readinessStreak {
    if (_readiness.isEmpty) return 0;
    var streak = 0;
    DateTime? previous;
    for (final snapshot in _readiness) {
      if (snapshot.score < 70) break;
      final date = DateTime(snapshot.date.year, snapshot.date.month, snapshot.date.day);
      if (previous != null && previous!.difference(date).inDays > 1) {
        break;
      }
      streak += 1;
      previous = date;
    }
    return streak;
  }

  double get readinessScoreAverage {
    if (_readiness.isEmpty) return 0;
    final sum = _readiness.fold<int>(0, (value, entry) => value + entry.score);
    return sum / _readiness.length;
  }

  void updateWellnessTargets({
    double? hydrationGoalLiters,
    double? sleepGoalHours,
    int? restingHeartRate,
    double? vo2Max,
    double? bodyAge,
    String? focusArea,
  }) {
    _profile = _profile.copyWith(
      hydrationGoalLiters: hydrationGoalLiters,
      sleepGoalHours: sleepGoalHours,
      restingHeartRate: restingHeartRate,
      vo2Max: vo2Max,
      bodyAge: bodyAge,
      focusArea: focusArea,
    );
    _persistProfile();
    notifyListeners();
  }

  void updateMacroTargets({int? calories, int? protein, int? carbs, int? fats}) {
    _macroTargets = _macroTargets.copyWith(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
    _persistMacroTargets();
    notifyListeners();
  }

  void logMeal(NutritionLog log) {
    _nutritionLogs.insert(0, log);
    if (_nutritionLogs.length > 24) {
      _nutritionLogs.removeLast();
    }
    _persistNutrition();
    notifyListeners();
  }

  void logSleep(SleepRecord record) {
    _sleepRecords.insert(0, record);
    if (_sleepRecords.length > 14) {
      _sleepRecords.removeLast();
    }
    _persistSleep();
    notifyListeners();
  }

  void addMindfulnessSession(MindfulnessSession session) {
    _mindfulnessSessions.insert(0, session);
    if (_mindfulnessSessions.length > 20) {
      _mindfulnessSessions.removeLast();
    }
    _persistMindfulness();
    notifyListeners();
  }

  void completeRecoveryRoutine(String id) {
    final index = _recoveryRoutines.indexWhere((routine) => routine.id == id);
    if (index == -1) return;
    final routine = _recoveryRoutines[index];
    final now = DateTime.now();
    final sameDay = routine.lastCompleted != null && _isSameDay(routine.lastCompleted!, now);
    final updated = routine.copyWith(
      streak: sameDay ? routine.streak : routine.streak + 1,
      lastCompleted: now,
      scheduledFor: now.add(const Duration(days: 2)),
    );
    _recoveryRoutines[index] = updated;
    _persistRecovery();
    notifyListeners();
  }

  static List<InbodyMeasurement> _seedInbodyHistory(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 8)
          .map(
            (parts) => InbodyMeasurement(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              weightKg: double.tryParse(parts[1]) ?? 0,
              bodyFatPercentage: double.tryParse(parts[2]) ?? 0,
              skeletalMuscleKg: double.tryParse(parts[3]) ?? 0,
              bodyWaterPercentage: double.tryParse(parts[4]) ?? 0,
              basalMetabolicRate: double.tryParse(parts[5]) ?? 0,
              visceralFatLevel: double.tryParse(parts[6]) ?? 0,
              bmi: double.tryParse(parts[7]) ?? 0,
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return List<InbodyMeasurement>.generate(4, (index) {
      final date = now.subtract(Duration(days: 28 * index));
      final randomShift = pow(-1, index) * (index * 0.4);
      return InbodyMeasurement(
        date: date,
        weightKg: 62.4 - index * 0.6,
        bodyFatPercentage: 21.2 - index * 0.5,
        skeletalMuscleKg: 26.4 + index * 0.3,
        bodyWaterPercentage: 57.0 + index * 0.4,
        basalMetabolicRate: 1380 + randomShift,
        visceralFatLevel: 7 - index * 0.3,
        bmi: 22.1 - index * 0.2,
      );
    });
  }

  static List<LoginRecord> _seedLoginHistory(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 4)
          .map(
            (parts) => LoginRecord(
              timestamp: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              method: parts[1],
              device: parts[2],
              successful: parts[3] == '1',
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return [
      LoginRecord(timestamp: now.subtract(const Duration(hours: 2)), method: 'password', device: 'Pixel 8 Pro', successful: true),
      LoginRecord(timestamp: now.subtract(const Duration(days: 1, hours: 3)), method: 'password', device: 'iPad Air', successful: true),
      LoginRecord(timestamp: now.subtract(const Duration(days: 3, hours: 5)), method: 'register', device: 'Web', successful: true),
    ];
  }

  static List<ProfileJournalEntry> _seedJournalEntries(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 6)
          .map(
            (parts) => ProfileJournalEntry(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              template: parts[1],
              energyLevel: int.tryParse(parts[2]) ?? 3,
              effortLevel: int.tryParse(parts[3]) ?? 3,
              synced: parts[4] == '1',
              tags: parts[5].isEmpty ? const [] : parts[5].split(','),
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return [
      ProfileJournalEntry(
        date: now.subtract(const Duration(days: 1, hours: 2)),
        template: 'strength',
        energyLevel: 4,
        effortLevel: 5,
        tags: const ['strength', 'progress'],
      ),
      ProfileJournalEntry(
        date: now.subtract(const Duration(days: 2, hours: 5)),
        template: 'recovery',
        energyLevel: 3,
        effortLevel: 2,
        tags: const ['recovery', 'hydration'],
      ),
      ProfileJournalEntry(
        date: now.subtract(const Duration(days: 4)),
        template: 'mobility',
        energyLevel: 5,
        effortLevel: 3,
        tags: const ['mobility', 'focus'],
      ),
    ];
  }

  static List<ReadinessSnapshot> _seedReadinessHistory(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 5)
          .map(
            (parts) => ReadinessSnapshot(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              score: int.tryParse(parts[1]) ?? 70,
              sleepHours: double.tryParse(parts[2]) ?? 7,
              hrv: double.tryParse(parts[3]) ?? 45,
              restingHeartRate: int.tryParse(parts[4]) ?? 52,
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return List.generate(5, (index) {
      final date = now.subtract(Duration(days: index));
      return ReadinessSnapshot(
        date: date,
        score: 78 + (index.isEven ? 4 : -2),
        sleepHours: 7.2 + (index * 0.1),
        hrv: 48 + index * 1.5,
        restingHeartRate: 52 - index,
      );
    });
  }

  static List<HydrationLog> _seedHydrationLogs(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 2)
          .map(
            (parts) => HydrationLog(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              liters: double.tryParse(parts[1]) ?? 0,
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return List.generate(4, (index) {
      final date = now.subtract(Duration(days: index));
      return HydrationLog(date: date, liters: 2.1 + index * 0.2);
    });
  }

  static List<PerformanceTrend> _seedPerformanceTrends(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      final seeded = <PerformanceTrend>[];
      for (final entry in cache) {
        final parts = entry.split('|');
        if (parts.length < 5) continue;
        final metric = parts[0];
        final week = double.tryParse(parts[1]) ?? 0;
        final month = double.tryParse(parts[2]) ?? 0;
        final lastUpdated = DateTime.tryParse(parts[3]) ?? DateTime.now();
        final points = parts[4]
            .split(';')
            .where((segment) => segment.isNotEmpty)
            .map((segment) {
          final pointParts = segment.split(',');
          if (pointParts.length != 2) return null;
          return TrendPoint(
            date: DateTime.tryParse(pointParts[0]) ?? DateTime.now(),
            value: double.tryParse(pointParts[1]) ?? 0,
          );
        }).whereType<TrendPoint>().toList();
        seeded.add(
          PerformanceTrend(
            metric: metric,
            points: points,
            weekChange: week,
            monthChange: month,
            lastUpdated: lastUpdated,
          ),
        );
      }
      if (seeded.isNotEmpty) {
        return seeded;
      }
    }
    final now = DateTime.now();
    PerformanceTrend buildTrend(String metric, List<double> values) {
      final points = List.generate(values.length, (index) {
        final date = now.subtract(Duration(days: index * 2));
        return TrendPoint(date: date, value: values[index]);
      });
      final latest = values.first;
      final previous = values.length > 1 ? values[1] : latest;
      final monthBaseline = values.length > 6 ? values[6] : values.last;
      return PerformanceTrend(
        metric: metric,
        points: points,
        weekChange: double.parse((latest - previous).toStringAsFixed(1)),
        monthChange: double.parse((latest - monthBaseline).toStringAsFixed(1)),
        lastUpdated: now.subtract(const Duration(hours: 2)),
      );
    }

    return [
      buildTrend('strength', [92.4, 91.8, 91.1, 90.6, 90.2, 89.4, 88.7]),
      buildTrend('endurance', [88.3, 87.9, 87.4, 87.0, 86.5, 86.1, 85.5]),
      buildTrend('mobility', [84.8, 84.2, 83.9, 83.4, 83.0, 82.7, 82.0]),
    ];
  }

  static List<PerformanceMilestone> _seedPerformanceMilestones(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      final seeded = <PerformanceMilestone>[];
      for (final entry in cache) {
        final parts = entry.split('|');
        if (parts.length < 7) continue;
        seeded.add(
          PerformanceMilestone(
            id: parts[0],
            title: parts[1],
            description: parts[2],
            scheduledFor: DateTime.tryParse(parts[3]) ?? DateTime.now(),
            badge: parts[4],
            achieved: parts[5] == '1',
            achievedOn: parts[6].isEmpty ? null : DateTime.tryParse(parts[6]),
          ),
        );
      }
      if (seeded.isNotEmpty) {
        return seeded;
      }
    }
    final now = DateTime.now();
    return [
      PerformanceMilestone(
        id: 'milestone_strength_elite',
        title: 'Strength elite 95',
        description: 'Hold a rolling strength score above 95 for a full week.',
        scheduledFor: now.add(const Duration(days: 10)),
        badge: 'ELITE',
      ),
      PerformanceMilestone(
        id: 'milestone_endurance_pr',
        title: 'Endurance PR',
        description: 'Log a sub-24 minute 5K with steady heart rate control.',
        scheduledFor: now.add(const Duration(days: 17)),
        badge: 'PR',
      ),
      PerformanceMilestone(
        id: 'milestone_mobility_flow',
        title: 'Mobility flow streak',
        description: 'Complete six guided mobility flows this month.',
        scheduledFor: now.subtract(const Duration(days: 3)),
        badge: 'FLOW',
        achieved: true,
        achievedOn: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static MacroTargets _seedMacroTargets(SharedPreferences prefs) {
    return MacroTargets(
      calories: prefs.getInt('macro_calories') ?? 2100,
      protein: prefs.getInt('macro_protein') ?? 135,
      carbs: prefs.getInt('macro_carbs') ?? 240,
      fats: prefs.getInt('macro_fats') ?? 60,
    );
  }

  static List<NutritionLog> _seedNutritionLogs(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 7)
          .map(
            (parts) => NutritionLog(
              timestamp: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              mealType: parts[1],
              calories: int.tryParse(parts[2]) ?? 0,
              protein: int.tryParse(parts[3]) ?? 0,
              carbs: int.tryParse(parts[4]) ?? 0,
              fats: int.tryParse(parts[5]) ?? 0,
              mood: parts[6].isEmpty ? null : parts[6],
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return [
      NutritionLog(
        timestamp: now.subtract(const Duration(hours: 1)),
        mealType: 'Recovery bowl',
        calories: 540,
        protein: 42,
        carbs: 52,
        fats: 18,
        mood: 'Focused',
      ),
      NutritionLog(
        timestamp: now.subtract(const Duration(hours: 5)),
        mealType: 'Green smoothie',
        calories: 320,
        protein: 25,
        carbs: 30,
        fats: 8,
        mood: 'Energised',
      ),
      NutritionLog(
        timestamp: now.subtract(const Duration(hours: 9)),
        mealType: 'Overnight oats',
        calories: 410,
        protein: 28,
        carbs: 46,
        fats: 12,
        mood: 'Balanced',
      ),
    ];
  }

  static List<SleepRecord> _seedSleepRecords(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 4)
          .map(
            (parts) => SleepRecord(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              hours: double.tryParse(parts[1]) ?? 7.2,
              quality: int.tryParse(parts[2]) ?? 80,
              readinessImpact: int.tryParse(parts[3]) ?? 76,
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return List.generate(5, (index) {
      final date = now.subtract(Duration(days: index));
      return SleepRecord(
        date: date,
        hours: 7.1 + (index.isEven ? 0.3 : -0.2),
        quality: 82 + (index * 2),
        readinessImpact: 78 + (index.isEven ? 3 : -2),
      );
    });
  }

  static List<MindfulnessSession> _seedMindfulnessSessions(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 4)
          .map(
            (parts) => MindfulnessSession(
              date: DateTime.tryParse(parts[0]) ?? DateTime.now(),
              durationMinutes: int.tryParse(parts[1]) ?? 5,
              technique: parts[2],
              moodAfter: parts[3],
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return [
      MindfulnessSession(
        date: now.subtract(const Duration(hours: 3)),
        durationMinutes: 8,
        technique: 'Box breathing',
        moodAfter: 'Calm',
      ),
      MindfulnessSession(
        date: now.subtract(const Duration(days: 1, hours: 1)),
        durationMinutes: 5,
        technique: 'Body scan',
        moodAfter: 'Present',
      ),
      MindfulnessSession(
        date: now.subtract(const Duration(days: 2, hours: 4)),
        durationMinutes: 10,
        technique: 'Visualization',
        moodAfter: 'Motivated',
      ),
    ];
  }

  static List<RecoveryRoutine> _seedRecoveryRoutines(List<String>? cache) {
    if (cache != null && cache.isNotEmpty) {
      return cache
          .map((entry) => entry.split('|'))
          .where((parts) => parts.length == 8)
          .map(
            (parts) => RecoveryRoutine(
              id: parts[0],
              title: parts[1],
              focus: parts[2],
              durationMinutes: int.tryParse(parts[3]) ?? 0,
              equipment: parts[4],
              streak: int.tryParse(parts[5]) ?? 0,
              lastCompleted:
                  parts[6].isEmpty ? null : DateTime.tryParse(parts[6]),
              scheduledFor:
                  parts[7].isEmpty ? null : DateTime.tryParse(parts[7]),
            ),
          )
          .toList();
    }
    final now = DateTime.now();
    return [
      RecoveryRoutine(
        id: 'recover_mobility',
        title: 'Mobility unwind',
        focus: 'Mobility',
        durationMinutes: 12,
        equipment: 'Mat',
        streak: 3,
        lastCompleted: now.subtract(const Duration(days: 1)),
        scheduledFor: now.add(const Duration(days: 1)),
      ),
      RecoveryRoutine(
        id: 'recover_cold',
        title: 'Contrast shower',
        focus: 'Circulation',
        durationMinutes: 9,
        equipment: 'Home',
        streak: 1,
        lastCompleted: now.subtract(const Duration(days: 2)),
        scheduledFor: now.add(const Duration(days: 2)),
      ),
      RecoveryRoutine(
        id: 'recover_breathe',
        title: 'Breathing ladder',
        focus: 'Parasympathetic',
        durationMinutes: 7,
        equipment: 'None',
        streak: 5,
        lastCompleted: now.subtract(const Duration(hours: 20)),
        scheduledFor: now.add(const Duration(hours: 20)),
      ),
    ];
  }

  void _persistProfile() {
    _prefs
      ..setString('user_displayName', _profile.name)
      ..setString('user_email', _profile.email)
      ..setInt('user_memberSince', _profile.memberSince.millisecondsSinceEpoch)
      ..setInt('user_lastInbodyEpoch', _profile.lastInbodySync?.millisecondsSinceEpoch ?? 0);
    if (_profile.heightCm != null) {
      _prefs.setInt('user_heightCm', _profile.heightCm!);
    } else {
      _prefs.remove('user_heightCm');
    }
    if (_profile.weightKg != null) {
      _prefs.setDouble('user_weightKg', _profile.weightKg!);
    } else {
      _prefs.remove('user_weightKg');
    }
    if (_profile.age != null) {
      _prefs.setInt('user_age', _profile.age!);
    } else {
      _prefs.remove('user_age');
    }
    if (_profile.gender != null && _profile.gender!.isNotEmpty) {
      _prefs.setString('user_gender', _profile.gender!);
    } else {
      _prefs.remove('user_gender');
    }
    if (_profile.goal != null && _profile.goal!.isNotEmpty) {
      _prefs.setString('user_goal', _profile.goal!);
    } else {
      _prefs.remove('user_goal');
    }
    if (_profile.restingHeartRate != null) {
      _prefs.setInt('user_restingHeartRate', _profile.restingHeartRate!);
    } else {
      _prefs.remove('user_restingHeartRate');
    }
    if (_profile.vo2Max != null) {
      _prefs.setDouble('user_vo2Max', _profile.vo2Max!);
    } else {
      _prefs.remove('user_vo2Max');
    }
    if (_profile.sleepGoalHours != null) {
      _prefs.setDouble('user_sleepGoalHours', _profile.sleepGoalHours!);
    } else {
      _prefs.remove('user_sleepGoalHours');
    }
    if (_profile.hydrationGoalLiters != null) {
      _prefs.setDouble('user_hydrationGoalLiters', _profile.hydrationGoalLiters!);
    } else {
      _prefs.remove('user_hydrationGoalLiters');
    }
    if (_profile.bodyAge != null) {
      _prefs.setDouble('user_bodyAge', _profile.bodyAge!);
    } else {
      _prefs.remove('user_bodyAge');
    }
    if (_profile.focusArea != null && _profile.focusArea!.isNotEmpty) {
      _prefs.setString('user_focusArea', _profile.focusArea!);
    } else {
      _prefs.remove('user_focusArea');
    }
  }

  void _persistInbody() {
    _prefs.setStringList('user_inbody_history', _inbodyHistory
        .map(
          (e) => [
                e.date.toIso8601String(),
                e.weightKg.toStringAsFixed(1),
                e.bodyFatPercentage.toStringAsFixed(1),
                e.skeletalMuscleKg.toStringAsFixed(1),
                e.bodyWaterPercentage.toStringAsFixed(1),
                e.basalMetabolicRate.toStringAsFixed(0),
                e.visceralFatLevel.toStringAsFixed(1),
                e.bmi.toStringAsFixed(1),
              ].join('|'),
        )
        .toList());
  }

  void _persistJournal() {
    _prefs.setStringList(
      'user_journal_entries',
      _journalEntries
          .map(
            (e) => [
                  e.date.toIso8601String(),
                  e.template,
                  e.energyLevel.toString(),
                  e.effortLevel.toString(),
                  e.synced ? '1' : '0',
                  e.tags.join(','),
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistLogins() {
    _prefs.setStringList(
      'user_login_history',
      _loginHistory
          .map(
            (e) => [
                  e.timestamp.toIso8601String(),
                  e.method,
                  e.device,
                  e.successful ? '1' : '0',
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistReadiness() {
    _prefs.setStringList(
      'user_readiness_history',
      _readiness
          .map(
            (e) => [
                  e.date.toIso8601String(),
                  e.score.toString(),
                  e.sleepHours.toStringAsFixed(1),
                  e.hrv.toStringAsFixed(1),
                  e.restingHeartRate.toString(),
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistHydration() {
    _prefs.setStringList(
      'user_hydration_logs',
      _hydrationLogs
          .map(
            (e) => [
                  e.date.toIso8601String(),
                  e.liters.toStringAsFixed(2),
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistPerformanceTrends() {
    _prefs.setStringList(
      'user_performance_trends',
      _performanceTrends
          .map(
            (e) => [
                  e.metric,
                  e.weekChange.toStringAsFixed(1),
                  e.monthChange.toStringAsFixed(1),
                  e.lastUpdated.toIso8601String(),
                  e.points
                      .map(
                        (point) =>
                            '${point.date.toIso8601String()},${point.value.toStringAsFixed(1)}',
                      )
                      .join(';'),
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistPerformanceMilestones() {
    _prefs.setStringList(
      'user_performance_milestones',
      _milestones
          .map(
            (e) => [
                  e.id,
                  e.title,
                  e.description,
                  e.scheduledFor.toIso8601String(),
                  e.badge,
                  e.achieved ? '1' : '0',
                  e.achievedOn?.toIso8601String() ?? '',
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistMacroTargets() {
    _prefs
      ..setInt('macro_calories', _macroTargets.calories)
      ..setInt('macro_protein', _macroTargets.protein)
      ..setInt('macro_carbs', _macroTargets.carbs)
      ..setInt('macro_fats', _macroTargets.fats);
  }

  void _persistNutrition() {
    _prefs.setStringList(
      'user_nutrition_logs',
      _nutritionLogs
          .map(
            (log) => [
                  log.timestamp.toIso8601String(),
                  log.mealType,
                  log.calories.toString(),
                  log.protein.toString(),
                  log.carbs.toString(),
                  log.fats.toString(),
                  log.mood ?? '',
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistSleep() {
    _prefs.setStringList(
      'user_sleep_records',
      _sleepRecords
          .map(
            (record) => [
                  record.date.toIso8601String(),
                  record.hours.toStringAsFixed(1),
                  record.quality.toString(),
                  record.readinessImpact.toString(),
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistMindfulness() {
    _prefs.setStringList(
      'user_mindfulness_sessions',
      _mindfulnessSessions
          .map(
            (session) => [
                  session.date.toIso8601String(),
                  session.durationMinutes.toString(),
                  session.technique,
                  session.moodAfter,
                ].join('|'),
          )
          .toList(),
    );
  }

  void _persistRecovery() {
    _prefs.setStringList(
      'user_recovery_routines',
      _recoveryRoutines
          .map(
            (routine) => [
                  routine.id,
                  routine.title,
                  routine.focus,
                  routine.durationMinutes.toString(),
                  routine.equipment,
                  routine.streak.toString(),
                  routine.lastCompleted?.toIso8601String() ?? '',
                  routine.scheduledFor?.toIso8601String() ?? '',
                ].join('|'),
          )
          .toList(),
    );
  }

  static DateTime? _restoreDate(int? value) {
    if (value == null || value == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static int? _readOptionalInt(SharedPreferences prefs, String key) {
    if (!prefs.containsKey(key)) return null;
    final value = prefs.getInt(key);
    if (value == null || value == 0) return null;
    return value;
  }

  static double? _readOptionalDouble(SharedPreferences prefs, String key) {
    if (!prefs.containsKey(key)) return null;
    final value = prefs.getDouble(key);
    if (value == null || value == 0) return null;
    return value;
  }

  static String? _readOptionalString(SharedPreferences prefs, String key) {
    if (!prefs.containsKey(key)) return null;
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
