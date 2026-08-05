import '../entities/attendance_today_entity.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistoryUseCase {
  final AttendanceRepository repository;
  const GetAttendanceHistoryUseCase(this.repository);

  Future<List<AttendanceTodayEntity>> call({
    String? startDate,
    String? endDate,
  }) {
    return repository.getHistory(startDate: startDate, endDate: endDate);
  }
}