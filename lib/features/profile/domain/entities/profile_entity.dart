class ScheduleStatusEntity {
  final bool isLibur;
  final String? shiftName;
  final String? shiftTime;

  const ScheduleStatusEntity({
    required this.isLibur,
    this.shiftName,
    this.shiftTime,
  });
}

class ProfileEntity {
  final int id;
  final String username;
  final String email;
  final String employeeNumber;
  final String name;
  final String gender;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final String? profession;
  final String? nationalIdNumber;
  final String? address;
  final String? phone;
  final String? maritalStatus;
  final String? educationLevel;
  final String? educationMajor;
  final String? photoUrl;
  final String? hireDate;
  final String? position;
  final String? department;
  final ScheduleStatusEntity? scheduleToday;
  final ScheduleStatusEntity? scheduleTomorrow;
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
    this.profession,
    this.address,
    this.phone,
    this.maritalStatus,
    this.educationLevel,
    this.educationMajor,
    this.photoUrl,
    this.hireDate,
    this.position,
    this.department,
    this.scheduleToday,
    this.scheduleTomorrow,
    required this.isActive,
  });
}