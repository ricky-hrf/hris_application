import '../entities/leave_type_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveTypesUseCase {
  final LeaveRepository repository;
  const GetLeaveTypesUseCase(this.repository);

  Future<List<LeaveTypeEntity>> call() => repository.getLeaveTypes();
}