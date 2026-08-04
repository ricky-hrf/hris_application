import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
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
  }) {
    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (gender != null) fields['gender'] = gender;
    if (placeOfBirth != null) fields['place_of_birth'] = placeOfBirth;
    if (dateOfBirth != null) fields['date_of_birth'] = dateOfBirth;
    if (nationalIdNumber != null) fields['national_id_number'] = nationalIdNumber;
    if (address != null) fields['address'] = address;
    if (phone != null) fields['phone'] = phone;
    if (maritalStatus != null) fields['marital_status'] = maritalStatus;
    if (educationLevel != null) fields['education_level'] = educationLevel;
    if (educationMajor != null) fields['education_major'] = educationMajor;

    return remoteDataSource.updateProfile(fields: fields, photoPath: photoPath);
  }
}