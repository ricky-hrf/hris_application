import '../entities/leave_request_entity.dart';
import '../repositories/leave_repository.dart';

class GetMyLeaveRequestsUseCase {
  final LeaveRepository repository;
  const GetMyLeaveRequestsUseCase(this.repository);

  Future<List<LeaveRequestEntity>> call() => repository.getMyRequests();
}