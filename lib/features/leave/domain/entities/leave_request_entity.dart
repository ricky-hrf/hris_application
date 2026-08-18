import 'leave_approval_entity.dart';

class LeaveRequestEntity {
  final int id;
  final int leaveTypeId;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String reason;
  final String? attachment;
  final String status;
  final List<LeaveApprovalEntity> approvals;

  const LeaveRequestEntity({
    required this.id,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.attachment,
    required this.status,
    required this.approvals,
  });
}