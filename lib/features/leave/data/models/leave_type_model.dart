import '../../domain/entities/leave_type_entity.dart';

class LeaveTypeModel extends LeaveTypeEntity {
  const LeaveTypeModel({
    required super.id,
    required super.code,
    required super.name,
    required super.requiresQuota,
    required super.remainingQuota,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      requiresQuota: json['requires_quota'] as bool,
      remainingQuota: json['remaining_quota'] as int?,
    );
  }
}