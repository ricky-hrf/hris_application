import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.name,
    super.photoUrl,
    super.employmentStatus,
    super.position,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserModel(
      id: user['id'] as int,
      username: user['username'] as String,
      email: user['email'] as String,
      token: json['token'] as String,
    );
  }

  factory UserModel.fromProfileJson(Map<String, dynamic> json, {required String existingToken}) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      employmentStatus: json['employment_status'] as String?,
      position: json['position'] as String?,
      token: existingToken,
    );
  }
}