import '../repositories/sp_letter_repository.dart';

class GetSpLetterUnreadCountUseCase {
  final SpLetterRepository repository;
  const GetSpLetterUnreadCountUseCase(this.repository);

  Future<int> call() => repository.getUnreadCount();
}