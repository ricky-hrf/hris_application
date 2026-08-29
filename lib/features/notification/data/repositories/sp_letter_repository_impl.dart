import '../../domain/entities/sp_letter_summary_entity.dart';
import '../../domain/entities/sp_letter_detail_entity.dart';
import '../../domain/repositories/sp_letter_repository.dart';
import '../datasources/sp_letter_remote_datasource.dart';

class SpLetterRepositoryImpl implements SpLetterRepository {
  final SpLetterRemoteDataSource remoteDataSource;
  const SpLetterRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SpLetterSummaryEntity>> getMyLetters() => remoteDataSource.getMyLetters();

  @override
  Future<SpLetterDetailEntity> getLetterDetail(int id) => remoteDataSource.getLetterDetail(id);

  @override
  Future<int> getUnreadCount() => remoteDataSource.getUnreadCount();
}