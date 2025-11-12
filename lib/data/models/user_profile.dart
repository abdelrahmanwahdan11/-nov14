class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.memberSince,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.lastInbodySync,
  });

  final String name;
  final String email;
  final DateTime memberSince;
  final int? age;
  final String? gender;
  final int? heightCm;
  final double? weightKg;
  final String? goal;
  final DateTime? lastInbodySync;

  UserProfile copyWith({
    String? name,
    String? email,
    DateTime? memberSince,
    int? age,
    String? gender,
    int? heightCm,
    double? weightKg,
    String? goal,
    DateTime? lastInbodySync,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      lastInbodySync: lastInbodySync ?? this.lastInbodySync,
    );
  }
}

class InbodyMeasurement {
  const InbodyMeasurement({
    required this.date,
    required this.weightKg,
    required this.bodyFatPercentage,
    required this.skeletalMuscleKg,
    required this.bodyWaterPercentage,
    required this.basalMetabolicRate,
    required this.visceralFatLevel,
    required this.bmi,
    this.notes,
  });

  final DateTime date;
  final double weightKg;
  final double bodyFatPercentage;
  final double skeletalMuscleKg;
  final double bodyWaterPercentage;
  final double basalMetabolicRate;
  final double visceralFatLevel;
  final double bmi;
  final String? notes;
}

class LoginRecord {
  const LoginRecord({
    required this.timestamp,
    required this.method,
    required this.device,
    required this.successful,
  });

  final DateTime timestamp;
  final String method;
  final String device;
  final bool successful;
}

class ProfileJournalEntry {
  const ProfileJournalEntry({
    required this.date,
    required this.template,
    required this.tags,
    required this.energyLevel,
    required this.effortLevel,
    this.synced = true,
  });

  final DateTime date;
  final String template;
  final List<String> tags;
  final int energyLevel;
  final int effortLevel;
  final bool synced;
}
