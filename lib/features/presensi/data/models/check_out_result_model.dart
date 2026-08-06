import '../../domain/entities/check_out_result_entity.dart';

class CheckOutResultModel extends CheckOutResultEntity {
  const CheckOutResultModel({
    required super.checkedAt,
    required super.distanceMeters,
    super.attendanceStatus,
  });

  factory CheckOutResultModel.fromJson(Map<String, dynamic> json) {
    final checkOut = json['check_out'] as Map<String, dynamic>?;
    final status = json['status'] as Map<String, dynamic>?;

    return CheckOutResultModel(
      checkedAt: checkOut?['checked_at'] as String? ?? '',
      distanceMeters: checkOut?['distance_meters'] as int? ?? 0,
      attendanceStatus: status?['name'] as String?,
    );
  }
}