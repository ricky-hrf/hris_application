import '../../domain/entities/sp_letter_detail_entity.dart';

class SpLetterDetailModel extends SpLetterDetailEntity {
  const SpLetterDetailModel({
    required super.id,
    required super.spNumber,
    required super.fileUrl,
    required super.issuedAt,
    super.viewedAt,
  });

  factory SpLetterDetailModel.fromJson(Map<String, dynamic> json) {
    return SpLetterDetailModel(
      id: json['id'] as int,
      spNumber: json['sp_number'] as int,
      fileUrl: json['file_url'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      viewedAt: json['viewed_at'] != null ? DateTime.parse(json['viewed_at'] as String) : null,
    );
  }
}