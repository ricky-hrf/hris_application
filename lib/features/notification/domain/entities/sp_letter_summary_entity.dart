class SpLetterSummaryEntity {
  final int id;
  final int spNumber;
  final DateTime issuedAt;
  final DateTime? viewedAt;

  const SpLetterSummaryEntity({
    required this.id,
    required this.spNumber,
    required this.issuedAt,
    this.viewedAt,
  });

  bool get isUnread => viewedAt == null;
}