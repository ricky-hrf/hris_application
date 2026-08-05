import '../entities/attendance_today_entity.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository repository;
  const GetTodayAttendanceUseCase(this.repository);

  Future<AttendanceTodayEntity?> call() => repository.getToday();
}