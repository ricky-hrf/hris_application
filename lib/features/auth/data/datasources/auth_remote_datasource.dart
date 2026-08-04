import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login({required String username, required String password}) async {
    final json = await client.post(
      ApiEndpoints.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    final data = json['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}