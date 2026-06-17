import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/liked_selfie_model.dart';

class LikedSelfiesRepository {
  final ApiClient _client;

  LikedSelfiesRepository(this._client);

  Future<({List<LikedSelfieModel> selfies, bool hasMore})> fetchLikedSelfies({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _client.get(
      ApiEndpoints.getLikedSelfies,
      requiresAuth: true,
      queryParams: {'page': page.toString(), 'perPage': perPage.toString()},
    );
    final outer = (response['data'] as Map<String, dynamic>?) ?? {};
    final list = (outer['data'] as List?) ?? [];
    final totalPages = (outer['total_pages'] as num?)?.toInt() ?? 1;
    final selfies = list
        .whereType<Map<String, dynamic>>()
        .map(LikedSelfieModel.fromJson)
        .toList();
    return (selfies: selfies, hasMore: page < totalPages);
  }

  Future<void> unlikeSelfie(String id) async {
    await _client.post(
      ApiEndpoints.unlikeSelfie(id),
      requiresAuth: true,
    );
  }
}
