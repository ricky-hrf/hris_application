import '../../domain/entities/attendance_location_entity.dart';
import '../../domain/entities/attendance_today_entity.dart';
import '../../domain/entities/check_in_result_entity.dart';
import '../../domain/entities/check_out_result_entity.dart';
import '../../domain/entities/emergency_check_in_result_entity.dart';
import '../../domain/entities/emergency_status_entity.dart';
import '../../domain/entities/emergency_detail_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  const AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<AttendanceLocationEntity> getMyLocation() => remoteDataSource.getMyLocation();

  @override
  Future<CheckInResultEntity> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) {
    return remoteDataSource.checkIn(
      latitude: latitude,
      longitude: longitude,
      locationId: locationId,
      photoPath: photoPath,
    );
  }

  @override
  Future<CheckOutResultEntity> checkOut({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) {
    return remoteDataSource.checkOut(
      latitude: latitude,
      longitude: longitude,
      locationId: locationId,
      photoPath: photoPath,
    );
  }

  @override
  Future<AttendanceTodayEntity?> getToday() => remoteDataSource.getToday();

  @override
  Future<List<AttendanceTodayEntity>> getHistory({
    String? startDate,
    String? endDate,
  }) {
    return remoteDataSource.getHistory(startDate: startDate, endDate: endDate);
  }

  @override
  Future<EmergencyCheckInResultEntity> submitEmergencyCheckIn({
    required double latitude,
    required double longitude,
    required String reason,
    required String selfiePhotoPath,
    required String proofPhotoPath,
  }) {
    return remoteDataSource.submitEmergencyCheckIn(
      latitude: latitude,
      longitude: longitude,
      reason: reason,
      selfiePhotoPath: selfiePhotoPath,
      proofPhotoPath: proofPhotoPath,
    );
  }

  @override
  Future<EmergencyStatusEntity?> getTodayEmergencyStatus() => remoteDataSource.getTodayEmergencyStatus();

  @override
  Future<EmergencyDetailEntity> getEmergencyDetail(int id) => remoteDataSource.getEmergencyDetail(id);

  @override
  Future<List<EmergencyStatusEntity>> getMyEmergencyHistory() => remoteDataSource.getMyEmergencyHistory();

}