import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/user_profile_stats_model.dart';
import 'package:happer_app/features/profile/models/user_selfie_model.dart';

class ImageGridRepository {
  final ApiClient _client;

  ImageGridRepository(this._client);

  Future<UserProfileStatsModel> fetchStats(String userId) async {
    final response = await _client.get(
      ApiEndpoints.userProfileStats(userId),
      requiresAuth: true,
    );
    return UserProfileStatsModel.fromJson(response);
  }

  Future<({List<UserSelfieModel> selfies, bool hasMore, int totalPages})>
      fetchSelfies(String userId, {int page = 1, int perPage = 12}) async {
    final response = await _client.get(
      ApiEndpoints.userSelfies(userId),
      requiresAuth: true,
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
    );
    final outer = (response['data'] as Map<String, dynamic>?) ?? {};
    final list = (outer['data'] as List?) ?? [];
    final selfies =
        list.map((e) => UserSelfieModel.fromJson(e as Map<String, dynamic>)).toList();
    final totalPages = (outer['total_pages'] as num?)?.toInt() ?? 1;
    return (selfies: selfies, hasMore: page < totalPages, totalPages: totalPages);
  }

  Future<void> followUser(String userId) async {
    await _client.post(
      ApiEndpoints.follow,
      body: {'following_id': userId},
      requiresAuth: true,
    );
  }

  Future<void> unfollowUser(String userId) async {
    await _client.delete(
      ApiEndpoints.unfollow,
      body: {'following_id': userId},
      requiresAuth: true,
    );
  }
}
