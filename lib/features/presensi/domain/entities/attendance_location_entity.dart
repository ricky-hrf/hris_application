class AttendanceLocationEntity {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;

  const AttendanceLocationEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });
}