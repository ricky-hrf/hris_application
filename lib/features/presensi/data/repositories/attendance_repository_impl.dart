import '../../domain/entities/attendance_location_entity.dart';
import '../../domain/entities/check_in_result_entity.dart';
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
}