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
        ),
        _inbodyHistory = _seedInbodyHistory(prefs.getStringList('user_inbody_history')),
        _loginHistory = _seedLoginHistory(prefs.getStringList('user_login_history'));

  final SharedPreferences _prefs;
  UserProfile _profile;
  final List<InbodyMeasurement> _inbodyHistory;
  final List<LoginRecord> _loginHistory;

  UserProfile get profile => _profile;
  List<InbodyMeasurement> get inbodyHistory => List.unmodifiable(_inbodyHistory);
  List<LoginRecord> get loginHistory => List.unmodifiable(_loginHistory);

  InbodyMeasurement? get latestMeasurement => _inbodyHistory.isEmpty ? null : _inbodyHistory.first;

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
}
