class EmergencyDetailEntity {
  final int id;
  final String checkedAt;
  final double latitude;
  final double longitude;
  final String? selfiePhotoUrl;
  final String? proofPhotoUrl;
  final String reason;
  final String status;
  final String? decisionNote;
  final String? decidedAt;

  const EmergencyDetailEntity({
    required this.id,
    required this.checkedAt,
    required this.latitude,
    required this.longitude,
    this.selfiePhotoUrl,
    this.proofPhotoUrl,
    required this.reason,
    required this.status,
    this.decisionNote,
    this.decidedAt,
  });
}