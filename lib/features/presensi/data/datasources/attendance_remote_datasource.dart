import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/attendance_location_model.dart';
import '../models/attendance_today_model.dart';
import '../models/check_in_result_model.dart';
import '../models/check_out_result_model.dart';
import '../models/emergency_check_in_result_model.dart';
import '../models/emergency_status_model.dart';
import '../models/emergency_detail_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceLocationModel> getMyLocation();
  Future<List<EmergencyStatusModel>> getMyEmergencyHistory();

  Future<CheckInResultModel> checkIn({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });

  Future<CheckOutResultModel> checkOut({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  });

  Future<AttendanceTodayModel?> getToday();

  Future<List<AttendanceTodayModel>> getHistory({
    String? startDate,
    String? endDate,
  });

  Future<EmergencyCheckInResultModel> submitEmergencyCheckIn({
    required double latitude,
    required double longitude,
    required String reason,
    required String selfiePhotoPath,
    required String proofPhotoPath,
  });

  Future<EmergencyStatusModel?> getTodayEmergencyStatus();

  Future<EmergencyDetailModel> getEmergencyDetail(int id);
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

  @override
  Future<CheckOutResultModel> checkOut({
    required double latitude,
    required double longitude,
    required int locationId,
    required String photoPath,
  }) async {
    final json = await client.postMultipart(
      ApiEndpoints.checkOut,
      fields: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_id': locationId.toString(),
      },
      filePath: photoPath,
      fileFieldName: 'photo',
      requireAuth: true,
    );
    return CheckOutResultModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<AttendanceTodayModel?> getToday() async {
    final json = await client.get(ApiEndpoints.attendanceToday, requireAuth: true);
    final data = json['data'];
    if (data == null) return null;
    return AttendanceTodayModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<AttendanceTodayModel>> getHistory({
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, String>{
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };

    final json = await client.get(
      ApiEndpoints.attendanceHistory,
      queryParameters: query.isEmpty ? null : query,
      requireAuth: true,
    );

    final list = json['data'] as List;
    return list
        .map((e) => AttendanceTodayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EmergencyCheckInResultModel> submitEmergencyCheckIn({
    required double latitude,
    required double longitude,
    required String reason,
    required String selfiePhotoPath,
    required String proofPhotoPath,
  }) async {
    final json = await client.postMultipartMultiFile(
      ApiEndpoints.emergencyCheckIn,
      fields: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'reason': reason,
      },
      files: {
        'selfie_photo': selfiePhotoPath,
        'proof_photo': proofPhotoPath,
      },
      requireAuth: true,
    );
    return EmergencyCheckInResultModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<EmergencyStatusModel?> getTodayEmergencyStatus() async {
    final json = await client.get(ApiEndpoints.emergencyCheckInToday, requireAuth: true);
    final data = json['data'];
    if (data == null) return null;
    return EmergencyStatusModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<EmergencyDetailModel> getEmergencyDetail(int id) async {
    final json = await client.get('${ApiEndpoints.emergencyCheckIn}/$id', requireAuth: true);
    return EmergencyDetailModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<EmergencyStatusModel>> getMyEmergencyHistory() async {
    final json = await client.get(ApiEndpoints.emergencyCheckInHistory, requireAuth: true);
    final list = json['data'] as List;
    return list.map((e) => EmergencyStatusModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}