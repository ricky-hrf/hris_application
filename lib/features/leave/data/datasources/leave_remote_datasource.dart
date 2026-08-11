import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/leave_type_model.dart';
import '../models/leave_request_model.dart';

abstract class LeaveRemoteDataSource {
  Future<List<LeaveTypeModel>> getLeaveTypes();

  Future<LeaveRequestModel> submitLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
  });

  Future<List<LeaveRequestModel>> getMyRequests();

  Future<LeaveRequestModel> getRequestDetail(int id);
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final ApiClient client;
  const LeaveRemoteDataSourceImpl(this.client);

  @override
  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final json = await client.get(ApiEndpoints.leaveTypes, requireAuth: true);
    final list = json['data'] as List;
    return list.map((e) => LeaveTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LeaveRequestModel> submitLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
  }) async {
    final fields = {
      'leave_type_id': leaveTypeId.toString(),
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    };

    final json = attachmentPath != null
        ? await client.postMultipart(
      ApiEndpoints.leaveRequests,
      fields: fields,
      filePath: attachmentPath,
      fileFieldName: 'attachment',
      requireAuth: true,
    )
        : await client.post(ApiEndpoints.leaveRequests, body: fields, requireAuth: true);

    return LeaveRequestModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<LeaveRequestModel>> getMyRequests() async {
    final json = await client.get(ApiEndpoints.leaveRequests, requireAuth: true);
    final list = json['data'] as List;
    return list.map((e) => LeaveRequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LeaveRequestModel> getRequestDetail(int id) async {
    final json = await client.get('${ApiEndpoints.leaveRequests}/$id', requireAuth: true);
    return LeaveRequestModel.fromJson(json['data'] as Map<String, dynamic>);
  }
}