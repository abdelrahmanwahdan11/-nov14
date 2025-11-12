class Session {
  const Session({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    required this.steps,
    required this.hrAvg,
    required this.distanceKm,
  });

  final String id;
  final String type;
  final DateTime start;
  final DateTime end;
  final int steps;
  final int hrAvg;
  final double distanceKm;
}
