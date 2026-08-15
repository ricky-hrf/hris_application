class EmergencyStatusEntity {
  final int id;
  final String checkedAt;
  final String emergencyStatus;
  final String emergencyReason;

  const EmergencyStatusEntity({
    required this.id,
    required this.checkedAt,
    required this.emergencyStatus,
    required this.emergencyReason,
  });
}