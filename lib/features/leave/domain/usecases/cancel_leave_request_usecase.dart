import '../repositories/leave_repository.dart';

class CancelLeaveRequestUseCase {
  final LeaveRepository repository;
  const CancelLeaveRequestUseCase(this.repository);

  Future<void> call(int id) => repository.cancelLeaveRequest(id);
}