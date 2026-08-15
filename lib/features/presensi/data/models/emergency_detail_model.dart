import '../../domain/entities/emergency_detail_entity.dart';

class EmergencyDetailModel extends EmergencyDetailEntity {
  const EmergencyDetailModel({
    required super.id,
    required super.checkedAt,
    required super.latitude,
    required super.longitude,
    super.selfiePhotoUrl,
    super.proofPhotoUrl,
    required super.reason,
    required super.status,
    super.decisionNote,
    super.decidedAt,
  });

  factory EmergencyDetailModel.fromJson(Map<String, dynamic> json) {
    return EmergencyDetailModel(
      id: json['id'] as int,
      checkedAt: json['checked_at'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      selfiePhotoUrl: json['selfie_photo_url'] as String?,
      proofPhotoUrl: json['proof_photo_url'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      decisionNote: json['decision_note'] as String?,
      decidedAt: json['decided_at'] as String?,
    );
  }
}