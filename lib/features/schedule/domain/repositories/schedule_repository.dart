import '../entities/schedule_day_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleDayEntity>> getMySchedule({required int year, required int month});
}