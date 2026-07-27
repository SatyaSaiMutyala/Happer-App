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
    var selfies =
        list.map((e) => UserSelfieModel.fromJson(e as Map<String, dynamic>)).toList();
    final totalPages = (outer['total_pages'] as num?)?.toInt() ?? 1;

    // This endpoint returns brand ids only, with no name/logo, so the grid has
    // nothing to draw. The creator-selfies endpoint returns the same looks with
    // `linked_brands` populated — fetch it and merge the logos in by selfie id.
    final brandsBySelfie =
        await _fetchBrandsBySelfie(userId, page: page, perPage: perPage);
    if (brandsBySelfie.isNotEmpty) {
      selfies = selfies
          .map((s) => brandsBySelfie.containsKey(s.id)
              ? s.copyWith(linkedBrands: brandsBySelfie[s.id])
              : s)
          .toList();
    }

    return (selfies: selfies, hasMore: page < totalPages, totalPages: totalPages);
  }

  /// selfie id → its tagged brands (`_id`, `name`, `picture`), deduped.
  /// Failures are swallowed: brand logos are decoration, so the grid must still
  /// render if this secondary call fails.
  Future<Map<String, List<Map<String, dynamic>>>> _fetchBrandsBySelfie(
    String userId, {
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.getCreatorSelfies,
        requiresAuth: true,
        queryParams: {
          'page': page.toString(),
          'perPage': perPage.toString(),
          'user_id': userId,
        },
      );
      final raw = response['data'];
      final list = raw is Map
          ? ((raw['data'] as List<dynamic>?) ?? [])
          : (raw is List ? raw : const []);

      final result = <String, List<Map<String, dynamic>>>{};
      for (final item in list.whereType<Map<String, dynamic>>()) {
        final id = item['_id'] as String? ?? '';
        if (id.isEmpty) continue;
        final seen = <String>{};
        final brands = <Map<String, dynamic>>[];
        for (final brand in (item['linked_brands'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()) {
          final brandId = brand['_id'] as String? ?? '';
          final picture = (brand['picture'] as String? ?? '').trim();
          if (brandId.isEmpty || picture.isEmpty) continue;
          if (seen.add(brandId)) brands.add(brand);
        }
        if (brands.isNotEmpty) result[id] = brands;
      }
      return result;
    } catch (_) {
      return {};
    }
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
