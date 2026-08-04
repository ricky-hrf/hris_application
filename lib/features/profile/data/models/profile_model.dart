import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity{
  const ProfileModel({
    required super.id,
    required super.username,
    required super.email,
    required super.employeeNumber,
    required super.name,
    required super.gender,
    super.placeOfBirth,
    super.dateOfBirth,
    super.nationalIdNumber,
    super.address,
    super.phone,
    super.maritalStatus,
    super.educationLevel,
    super.educationMajor,
    super.photoUrl,
    super.hireDate,
    required super.isActive,
});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      employeeNumber: json['employee_number'] as String? ?? '-',
      name: json['name'] as String? ?? '-',
      gender: json['gender'] as String? ?? '-',
      placeOfBirth: json['place_of_birth'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      nationalIdNumber: json['national_id_number'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      maritalStatus: json['marital_status'] as String?,
      educationLevel: json['education_level'] as String?,
      educationMajor: json['education_major'] as String?,
      photoUrl: json['photo_url'] as String?,
      hireDate: json['hire_date'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}