class EmergencyCheckInResultEntity {
  final int id;
  final String checkedAt;
  final String emergencyStatus;

  const EmergencyCheckInResultEntity({
    required this.id,
    required this.checkedAt,
    required this.emergencyStatus,
  });
}