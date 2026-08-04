import '../../domain/entities/check_in_result_entity.dart';

class CheckInResultModel extends CheckInResultEntity {
  const CheckInResultModel({
    required super.checkedAt,
    required super.distanceMeters,
    required super.status,
  });

  factory CheckInResultModel.fromJson(Map<String, dynamic> json) {
    return CheckInResultModel(
      checkedAt: json['checked_at'] as String,
      distanceMeters: json['distance_meters'] as int,
      status: json['status'] as String? ?? '-',
    );
  }
}