import '../entities/sp_letter_summary_entity.dart';
import '../entities/sp_letter_detail_entity.dart';

abstract class SpLetterRepository {
  Future<List<SpLetterSummaryEntity>> getMyLetters();
  Future<SpLetterDetailEntity> getLetterDetail(int id);
  Future<int> getUnreadCount();
}