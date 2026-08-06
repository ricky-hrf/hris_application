import '../entities/check_out_result_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckOutUseCase {
  final AttendanceRepository repository;
  const CheckOutUseCase(this.repository);

  Future<CheckOutResultEntity> call({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) {
    return repository.checkOut(
      latitude: latitude,
      longitude: longitude,
      locationId: locationId,
      photoPath: photoPath,
    );
  }
}