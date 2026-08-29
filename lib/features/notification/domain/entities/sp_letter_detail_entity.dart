class SpLetterDetailEntity {
  final int id;
  final int spNumber;
  final String fileUrl;
  final DateTime issuedAt;
  final DateTime? viewedAt;

  const SpLetterDetailEntity({
    required this.id,
    required this.spNumber,
    required this.fileUrl,
    required this.issuedAt,
    this.viewedAt,
  });

  bool get isImage {
    final lower = fileUrl.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
  }
}