import '../../domain/entities/leave_type_entity.dart';
import '../../domain/entities/leave_request_entity.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/leave_remote_datasource.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;
  const LeaveRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LeaveTypeEntity>> getLeaveTypes() => remoteDataSource.getLeaveTypes();

  @override
  Future<LeaveRequestEntity> submitLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
  }) {
    return remoteDataSource.submitLeaveRequest(
      leaveTypeId: leaveTypeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      attachmentPath: attachmentPath,
    );
  }

  @override
  Future<List<LeaveRequestEntity>> getMyRequests() => remoteDataSource.getMyRequests();

  @override
  Future<LeaveRequestEntity> getRequestDetail(int id) => remoteDataSource.getRequestDetail(id);
}