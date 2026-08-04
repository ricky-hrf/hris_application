import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/attendance_location_model.dart';
import '../models/check_in_result_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceLocationModel> getMyLocation();
  Future<CheckInResultModel> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient client;
  const AttendanceRemoteDataSourceImpl(this.client);

  @override
  Future<AttendanceLocationModel> getMyLocation() async {
    final json = await client.get(ApiEndpoints.attendanceLocation, requireAuth: true);
    return AttendanceLocationModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<CheckInResultModel> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) async {
    final json = await client.postMultipart(
      ApiEndpoints.checkIn,
      fields: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_id': locationId.toString(),
      },
      filePath: photoPath,
      fileFieldName: 'photo',
      requireAuth: true,
    );
    return CheckInResultModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}