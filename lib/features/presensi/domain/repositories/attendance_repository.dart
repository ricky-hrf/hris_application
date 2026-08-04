import '../entities/attendance_location_entity.dart';
import '../entities/check_in_result_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceLocationEntity> getMyLocation();

  Future<CheckInResultEntity> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });
}