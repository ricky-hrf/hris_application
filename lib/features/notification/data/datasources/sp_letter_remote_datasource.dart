import 'package:hris_application/core/network/api_client.dart';
import 'package:hris_application/core/network/api_endpoints.dart';
import '../models/sp_letter_summary_model.dart';
import '../models/sp_letter_detail_model.dart';

abstract class SpLetterRemoteDataSource {
  Future<List<SpLetterSummaryModel>> getMyLetters();
  Future<SpLetterDetailModel> getLetterDetail(int id);
  Future<int> getUnreadCount();
}

class SpLetterRemoteDataSourceImpl implements SpLetterRemoteDataSource {
  final ApiClient client;
  const SpLetterRemoteDataSourceImpl(this.client);

  @override
  Future<List<SpLetterSummaryModel>> getMyLetters() async {
    final json = await client.get(ApiEndpoints.spLetters, requireAuth: true);
    final list = json['data'] as List;
    return list.map((e) => SpLetterSummaryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SpLetterDetailModel> getLetterDetail(int id) async {
    final json = await client.get('${ApiEndpoints.spLetters}/$id', requireAuth: true);
    final data = json['data'] as Map<String, dynamic>;
    return SpLetterDetailModel.fromJson(data);
  }

  @override
  Future<int> getUnreadCount() async {
    final json = await client.get(ApiEndpoints.spLettersUnreadCount, requireAuth: true);
    return json['count'] as int? ?? 0;
  }
}