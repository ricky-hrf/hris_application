class ProfileEntity {
  final int id;
  final String username;
  final String email;
  final String employeeNumber;
  final String name;
  final String gender;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? nationalIdNumber;
  final String? address;
  final String? phone;
  final String? maritalStatus;
  final String? educationLevel;
  final String? educationMajor;
  final String? photoUrl;
  final String? hireDate;
  final bool isActive;

  const ProfileEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.employeeNumber,
    required this.name,
    required this.gender,
    this.placeOfBirth,
    this.dateOfBirth,
    this.nationalIdNumber,
    this.address,
    this.phone,
    this.maritalStatus,
    this.educationLevel,
    this.educationMajor,
    this.photoUrl,
    this.hireDate,
    required this.isActive,
});
}