class CheckInResultEntity {
  final String checkedAt;
  final int distanceMeters;
  final String status;

  const CheckInResultEntity({
    required this.checkedAt,
    required this.distanceMeters,
    required this.status,
  });
}