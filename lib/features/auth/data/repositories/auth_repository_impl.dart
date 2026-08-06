import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login({required String username, required String password}) async {
    final user = await remoteDataSource.login(username: username, password: password);
    await localDataSource.saveToken(user.token);
    return user;
  }

  @override
  Future<UserEntity> getProfile() async {
    final token = await localDataSource.getToken();
    if (token == null) {
      throw Exception('Sesi berakhir, silakan login ulang');
    }
    return remoteDataSource.getProfile(token: token);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearToken();
  }
}