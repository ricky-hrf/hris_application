import '../entities/leave_request_entity.dart';
import '../repositories/leave_repository.dart';

class SubmitLeaveRequestUseCase {
  final LeaveRepository repository;
  const SubmitLeaveRequestUseCase(this.repository);

  Future<LeaveRequestEntity> call({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachmentPath,
  }) {
    return repository.submitLeaveRequest(
      leaveTypeId: leaveTypeId,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      attachmentPath: attachmentPath,
    );
  }
}