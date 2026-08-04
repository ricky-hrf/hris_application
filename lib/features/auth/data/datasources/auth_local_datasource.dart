import '../../../../core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService storage;

  const AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveToken(String token) => storage.saveToken(token);

  @override
  Future<String?> getToken() => storage.getToken();

  @override
  Future<void> clearToken() => storage.deleteToken();
}