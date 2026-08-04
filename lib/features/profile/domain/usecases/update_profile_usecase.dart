import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    String? name,
    String? gender,
    String? placeOfBirth,
    String? dateOfBirth,
    String? nationalIdNumber,
    String? address,
    String? phone,
    String? maritalStatus,
    String? educationLevel,
    String? educationMajor,
    String? photoPath,
  }) {
    return repository.updateProfile(
      name: name,
      gender: gender,
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth,
      nationalIdNumber: nationalIdNumber,
      address: address,
      phone: phone,
      maritalStatus: maritalStatus,
      educationLevel: educationLevel,
      educationMajor: educationMajor,
      photoPath: photoPath,
    );
  }
}