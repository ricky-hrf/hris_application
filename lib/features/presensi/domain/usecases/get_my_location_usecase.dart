import '../entities/attendance_location_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMyLocationUseCase {
  final AttendanceRepository repository;
  const GetMyLocationUseCase(this.repository);

  Future<AttendanceLocationEntity> call() => repository.getMyLocation();
}