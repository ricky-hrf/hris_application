import '../entities/attendance_location_entity.dart';
import '../entities/attendance_today_entity.dart';
import '../entities/check_in_result_entity.dart';
import '../entities/check_out_result_entity.dart';
import '../entities/emergency_check_in_result_entity.dart';
import '../entities/emergency_status_entity.dart';
import '../entities/emergency_detail_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceLocationEntity> getMyLocation();

  Future<CheckInResultEntity> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });

  Future<CheckOutResultEntity> checkOut({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });

  Future<AttendanceTodayEntity?> getToday();

  Future<List<AttendanceTodayEntity>> getHistory({
    String? startDate,
    String? endDate,
  });

  Future<EmergencyCheckInResultEntity> submitEmergencyCheckIn({
    required double latitude,
    required double longitude,
    required String reason,
    required String selfiePhotoPath,
    required String proofPhotoPath,
  });

  Future<EmergencyStatusEntity?> getTodayEmergencyStatus();

  Future<EmergencyDetailEntity> getEmergencyDetail(int id);

  Future<List<EmergencyStatusEntity>> getMyEmergencyHistory();
}