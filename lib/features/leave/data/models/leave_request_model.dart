import '../../domain/entities/leave_request_entity.dart';
import 'leave_approval_model.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.id,
    required super.leaveTypeId,
    required super.leaveTypeName,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.reason,
    required super.attachment,
    required super.status,
    required super.approvals,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final leaveType = json['leave_type'] as Map<String, dynamic>?;
    final approvalsJson = json['approvals'] as List? ?? [];

    return LeaveRequestModel(
      id: json['id'] as int,
      leaveTypeId: json['leave_type_id'] as int,
      leaveTypeName: leaveType?['name'] as String? ?? '-',
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      totalDays: json['total_days'] as int,
      reason: json['reason'] as String,
      attachment: json['attachment'] as String?,
      status: json['status'] as String,
      approvals: approvalsJson
          .map((e) => LeaveApprovalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}