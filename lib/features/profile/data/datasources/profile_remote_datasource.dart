import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    Map<String, String> fields,
    String? photoPath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient client;

  const ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<ProfileModel> getProfile() async {
    final json = await client.get(
      ApiEndpoints.profile,
      requireAuth: true,
    );

    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> updateProfile({
    Map<String, String> fields = const {},
    String? photoPath,
  }) async {
    final json = await client.postMultipart(
      ApiEndpoints.profile,
      fields: {
        '_method': 'PUT',
        ...fields,
      },
      filePath: photoPath,
      fileFieldName: 'photo',
      requireAuth: true,
    );

    final data = json['data'] as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }
}