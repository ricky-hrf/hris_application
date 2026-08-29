import '../entities/sp_letter_detail_entity.dart';
import '../repositories/sp_letter_repository.dart';

class GetSpLetterDetailUseCase {
  final SpLetterRepository repository;
  const GetSpLetterDetailUseCase(this.repository);

  Future<SpLetterDetailEntity> call(int id) => repository.getLetterDetail(id);
}