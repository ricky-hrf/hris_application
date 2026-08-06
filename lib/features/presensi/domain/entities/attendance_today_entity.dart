class AttendanceTodayEntity {
  final String status;
  final String workDate;
  final String? shiftName;
  final String? checkInTime;
  final String? checkInPhotoUrl;
  final String? checkOutTime;
  final String? checkOutPhotoUrl;
  final String? attendanceStatus;

  const AttendanceTodayEntity({
    required this.status,
    required this.workDate,
    this.shiftName,
    this.checkInTime,
    this.checkInPhotoUrl,
    this.checkOutTime,
    this.checkOutPhotoUrl,
    this.attendanceStatus,
  });
}