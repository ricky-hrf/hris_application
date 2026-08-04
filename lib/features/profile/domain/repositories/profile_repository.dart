import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
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
  });
}