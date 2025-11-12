class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMin,
    required this.imageUrl,
    required this.targetMuscles,
    required this.intensity,
  });

  final String id;
  final String title;
  final String type;
  final int durationMin;
  final String imageUrl;
  final List<String> targetMuscles;
  final int intensity;
}
