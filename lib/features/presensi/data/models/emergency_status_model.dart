import '../../domain/entities/emergency_status_entity.dart';

class EmergencyStatusModel extends EmergencyStatusEntity {
  const EmergencyStatusModel({
    required super.id,
    required super.checkedAt,
    required super.emergencyStatus,
    required super.emergencyReason,
  });

  factory EmergencyStatusModel.fromJson(Map<String, dynamic> json) {
    return EmergencyStatusModel(
      id: json['id'] as int,
      checkedAt: json['checked_at'] as String,
      emergencyStatus: json['emergency_status'] as String,
      emergencyReason: json['emergency_reason'] as String,
    );
  }
}