import '../../domain/entities/attendance_today_entity.dart';

class AttendanceTodayModel extends AttendanceTodayEntity {
  const AttendanceTodayModel({
    required super.status,
    required super.workDate,
    super.shiftName,
    super.checkInTime,
    super.checkInPhotoUrl,
    super.checkOutTime,
    super.checkOutPhotoUrl,
    super.attendanceStatus,
  });

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) {
    return AttendanceTodayModel(
      status: json['status'] as String,
      workDate: json['work_date'] as String,
      shiftName: json['shift_name'] as String?,
      checkInTime: json['check_in_time'] as String?,
      checkInPhotoUrl: json['check_in_photo_url'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkOutPhotoUrl: json['check_out_photo_url'] as String?,
      attendanceStatus: json['attendance_status'] as String?,
    );
  }
}