import '../../domain/entities/leave_approval_entity.dart';

class LeaveApprovalModel extends LeaveApprovalEntity {
  const LeaveApprovalModel({
    required super.id,
    required super.sequence,
    required super.type,
    required super.status,
    required super.approverName,
    required super.approverPosition,
    super.decidedAt,
    super.note,
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalModel(
      id: json['id'] as int,
      sequence: json['sequence'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      approverName: json['approver_name'] as String,
      approverPosition: json['approver_position'] as String,
      decidedAt: json['decided_at'] as String?,
      note: json['note'] as String?,
    );
  }
}