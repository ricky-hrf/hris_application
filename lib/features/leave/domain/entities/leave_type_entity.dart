class LeaveTypeEntity {
  final int id;
  final String code;
  final String name;
  final bool requiresQuota;
  final int? remainingQuota;

  const LeaveTypeEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.requiresQuota,
    required this.remainingQuota,
  });
}