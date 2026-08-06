class CheckOutResultEntity {
  final String checkedAt;
  final int distanceMeters;
  final String? attendanceStatus;

  const CheckOutResultEntity({
    required this.checkedAt,
    required this.distanceMeters,
    this.attendanceStatus,
  });
}