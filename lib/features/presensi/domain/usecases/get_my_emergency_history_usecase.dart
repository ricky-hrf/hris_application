import '../entities/emergency_status_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMyEmergencyHistoryUseCase {
  final AttendanceRepository repository;
  const GetMyEmergencyHistoryUseCase(this.repository);

  Future<List<EmergencyStatusEntity>> call() => repository.getMyEmergencyHistory();
}