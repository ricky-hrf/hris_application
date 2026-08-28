class ShiftInfoEntity {
  final int id;
  final String code;
  final String name;
  final String? startTime;
  final String? endTime;

  const ShiftInfoEntity({
    required this.id,
    required this.code,
    required this.name,
    this.startTime,
    this.endTime,
  });
}

class ScheduleDayEntity {
  final DateTime date;
  final bool isLibur;
  final ShiftInfoEntity? shift;

  const ScheduleDayEntity({
    required this.date,
    required this.isLibur,
    this.shift,
  });
}