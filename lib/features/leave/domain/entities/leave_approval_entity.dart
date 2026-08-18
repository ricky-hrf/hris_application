class LeaveApprovalEntity {
  final int id;
  final int sequence;
  final String type;
  final String status;
  final String approverName;
  final String approverPosition;
  final String? decidedAt;
  final String? note;

  const LeaveApprovalEntity({
    required this.id,
    required this.sequence,
    required this.type,
    required this.status,
    required this.approverName,
    required this.approverPosition,
    this.decidedAt,
    this.note,
  });
}