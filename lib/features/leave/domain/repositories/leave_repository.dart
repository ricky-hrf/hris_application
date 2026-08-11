import '../entities/leave_type_entity.dart';
import '../entities/leave_request_entity.dart';

abstract class LeaveRepository {
  Future<List<LeaveTypeEntity>> getLeaveTypes();

  Future<LeaveRequestEntity> submitLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
  });

  Future<List<LeaveRequestEntity>> getMyRequests();

  Future<LeaveRequestEntity> getRequestDetail(int id);
}