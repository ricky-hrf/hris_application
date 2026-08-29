import '../entities/sp_letter_summary_entity.dart';
import '../repositories/sp_letter_repository.dart';

class GetMySpLettersUseCase {
  final SpLetterRepository repository;
  const GetMySpLettersUseCase(this.repository);

  Future<List<SpLetterSummaryEntity>> call() => repository.getMyLetters();
}