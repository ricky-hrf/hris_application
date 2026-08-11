import '../entities/leave_request_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveRequestDetailUseCase {
  final LeaveRepository repository;
  const GetLeaveRequestDetailUseCase(this.repository);

  Future<LeaveRequestEntity> call(int id) => repository.getRequestDetail(id);
}