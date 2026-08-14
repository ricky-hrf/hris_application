import '../../domain/entities/emergency_check_in_result_entity.dart';

class EmergencyCheckInResultModel extends EmergencyCheckInResultEntity {
  const EmergencyCheckInResultModel({
    required super.id,
    required super.checkedAt,
    required super.emergencyStatus,
  });

  factory EmergencyCheckInResultModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCheckInResultModel(
      id: json['id'] as int,
      checkedAt: json['checked_at'] as String,
      emergencyStatus: json['emergency_status'] as String,
    );
  }
}