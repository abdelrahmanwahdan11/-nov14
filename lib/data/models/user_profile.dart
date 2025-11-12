class UserProfile {
  const UserProfile({
    required this.name,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
  });

  final String name;
  final int? age;
  final String? gender;
  final int? heightCm;
  final double? weightKg;

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    int? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
