class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? employmentStatus;
  final String? position;
  final String token;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.photoUrl,
    this.employmentStatus,
    this.position,
    required this.token,
});
}