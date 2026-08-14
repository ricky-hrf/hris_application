import '../entities/emergency_check_in_result_entity.dart';
import '../repositories/attendance_repository.dart';

class SubmitEmergencyCheckInUseCase {
  final AttendanceRepository repository;
  const SubmitEmergencyCheckInUseCase(this.repository);

  Future<EmergencyCheckInResultEntity> call({
    required double latitude,
    required double longitude,
    required String reason,
    required String selfiePhotoPath,
    required String proofPhotoPath,
  }) {
    return repository.submitEmergencyCheckIn(
      latitude: latitude,
      longitude: longitude,
      reason: reason,
      selfiePhotoPath: selfiePhotoPath,
      proofPhotoPath: proofPhotoPath,
    );
  }
}