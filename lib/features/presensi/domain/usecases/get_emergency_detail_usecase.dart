import '../entities/emergency_detail_entity.dart';
import '../repositories/attendance_repository.dart';

class GetEmergencyDetailUseCase {
  final AttendanceRepository repository;
  const GetEmergencyDetailUseCase(this.repository);

  Future<EmergencyDetailEntity> call(int id) => repository.getEmergencyDetail(id);
}