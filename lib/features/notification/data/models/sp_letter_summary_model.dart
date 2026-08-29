import '../../domain/entities/sp_letter_summary_entity.dart';

class SpLetterSummaryModel extends SpLetterSummaryEntity {
  const SpLetterSummaryModel({
    required super.id,
    required super.spNumber,
    required super.issuedAt,
    super.viewedAt,
  });

  factory SpLetterSummaryModel.fromJson(Map<String, dynamic> json) {
    return SpLetterSummaryModel(
      id: json['id'] as int,
      spNumber: json['sp_number'] as int,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      viewedAt: json['viewed_at'] != null ? DateTime.parse(json['viewed_at'] as String) : null,
    );
  }
}