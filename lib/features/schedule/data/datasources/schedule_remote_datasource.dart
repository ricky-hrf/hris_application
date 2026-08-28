import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/schedule_day_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleDayModel>> getMySchedule({required int year, required int month});
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient client;
  const ScheduleRemoteDataSourceImpl(this.client);

  @override
  Future<List<ScheduleDayModel>> getMySchedule({required int year, required int month}) async {
    final json = await client.get(
      ApiEndpoints.scheduleMe,
      requireAuth: true,
      queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      },
    );

    final list = json['data'] as List;
    return list.map((e) => ScheduleDayModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}