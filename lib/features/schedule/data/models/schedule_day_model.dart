import '../../domain/entities/schedule_day_entity.dart';

class ShiftInfoModel extends ShiftInfoEntity {
  const ShiftInfoModel({
    required super.id,
    required super.code,
    required super.name,
    super.startTime,
    super.endTime,
  });

  factory ShiftInfoModel.fromJson(Map<String, dynamic> json) {
    return ShiftInfoModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '-',
      name: json['name'] as String? ?? '-',
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }
}

class ScheduleDayModel extends ScheduleDayEntity {
  const ScheduleDayModel({
    required super.date,
    required super.isLibur,
    super.shift,
  });

  factory ScheduleDayModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDayModel(
      date: DateTime.parse(json['date'] as String),
      isLibur: json['is_libur'] as bool? ?? false,
      shift: json['shift'] != null
          ? ShiftInfoModel.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
    );
  }
}