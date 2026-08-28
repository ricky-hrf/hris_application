import '../entities/schedule_day_entity.dart';
import '../repositories/schedule_repository.dart';

class GetMyScheduleUseCase {
  final ScheduleRepository repository;
  const GetMyScheduleUseCase(this.repository);

  Future<List<ScheduleDayEntity>> call({required int year, required int month}) {
    return repository.getMySchedule(year: year, month: month);
  }
}