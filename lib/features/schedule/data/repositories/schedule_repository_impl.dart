import '../../domain/entities/schedule_day_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  const ScheduleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ScheduleDayEntity>> getMySchedule({required int year, required int month}) {
    return remoteDataSource.getMySchedule(year: year, month: month);
  }
}