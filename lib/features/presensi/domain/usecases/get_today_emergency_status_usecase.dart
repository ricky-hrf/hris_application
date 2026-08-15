import '../entities/emergency_status_entity.dart';
import '../repositories/attendance_repository.dart';

class GetTodayEmergencyStatusUseCase {
  final AttendanceRepository repository;
  const GetTodayEmergencyStatusUseCase(this.repository);

  Future<EmergencyStatusEntity?> call() => repository.getTodayEmergencyStatus();
}