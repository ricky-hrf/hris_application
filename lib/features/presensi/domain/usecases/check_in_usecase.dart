import '../entities/check_in_result_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckInUseCase {
  final AttendanceRepository repository;
  const CheckInUseCase(this.repository);

  Future<CheckInResultEntity> call({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) {
    return repository.checkIn(latitude: latitude, longitude: longitude, locationId: locationId, photoPath: photoPath);
  }
}