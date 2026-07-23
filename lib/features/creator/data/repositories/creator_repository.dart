import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/creator/data/models/creator_selfie_model.dart';
import 'package:happer_app/features/creator/data/models/liked_product_model.dart';
import 'package:happer_app/features/creator/data/models/suggestion_model.dart';
import 'package:happer_app/features/creator/models/creator_model.dart';

class CreatorRepository {
  final ApiClient _client;

  CreatorRepository(this._client);

  Future<List<CreatorSelfieModel>> getCreatorSelfies({
    int page = 1,
    int perPage = 20,
    String? search,
    String? userId,
    String? brandId,
  }) async {
    final queryParams = <String, String>{'page': '$page', 'perPage': '$perPage'};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (userId != null && userId.trim().isNotEmpty) {
      queryParams['user_id'] = userId.trim();
    }
    if (brandId != null && brandId.trim().isNotEmpty) {
      queryParams['brand_id'] = brandId.trim();
    }
    final response = await _client.get(
      ApiEndpoints.getCreatorSelfies,
      requiresAuth: true,
      queryParams: queryParams,
    );
    final raw = response['data'];
    final List<dynamic> list;
    if (raw is Map) {
      list = (raw['data'] as List<dynamic>?) ?? [];
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(CreatorSelfieModel.fromJson)
        .toList();
  }

  Future<({
    CreatorModel selfie,
    List<Map<String, dynamic>> linkedProducts,
    List<Map<String, dynamic>> similarProducts,
    List<Map<String, dynamic>> brandCollections,
  })> getSelfieDetail(String id) async {
    final response = await _client.get(
      ApiEndpoints.getSelfieDetail(id),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>;
    final userId = data['user_id'] as Map<String, dynamic>?;
    final images = (data['images'] as List<dynamic>? ?? []).cast<String>();

    // Normalise any linked_products / similar_products item into a consistent shape.
    Map<String, dynamic> normalizeItem(
        Map<String, dynamic> item, Map<String, dynamic>? brandOverride) {
      final product = item['product_id'] as Map<String, dynamic>? ?? {};
      final variant = item['variant_id'] as Map<String, dynamic>? ?? {};
      final brand = brandOverride ?? (item['brand_id'] as Map<String, dynamic>? ?? {});
      final images = (variant['images'] as List<dynamic>? ?? [])
          .map((e) => (e as String).trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return <String, dynamic>{
        '_id': product['_id'],
        'name': product['name'],
        'brand_id': brand,
        // `variant_id` is only the variant tagged in the look. The remaining
        // sizes for the same product come through as `other_sizes`, so pass
        // them along for the "complete the look" size picker.
        'variants': [<String, dynamic>{...variant, 'images': images}],
        'other_sizes': item['other_sizes'] ?? const [],
      };
    }

    final linkedProducts = (data['linked_products'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => normalizeItem(item, null))
        .toList();

    final similarProducts = (data['similar_products'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => normalizeItem(item, null))
        .toList();

    final brandCollections = (data['recommended_products'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((group) {
          final brandMap = <String, dynamic>{
            '_id': group['brand_id'],
            'name': group['brand_name'],
            'picture': group['brand_picture'],
          };
          final products = (group['products'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .map((item) => normalizeItem(item, brandMap))
              .toList();
          return <String, dynamic>{'brand': brandMap, 'products': products};
        })
        .where((g) => (g['products'] as List).isNotEmpty)
        .toList();

    final selfie = CreatorModel(
      sId: data['_id'] as String? ?? '',
      picture: images.isNotEmpty ? images.first : null,
      images: images,
      caption: data['caption'] as String?,
      createdAt: data['created_at'] as String?,
      isLikedByMe: data['is_liked_by_me'] as bool? ?? false,
      nbLike: data['likes_count'] as int? ?? 0,
      user: userId != null
          ? User(
              sId: userId['_id'] as String?,
              userName: userId['username'] as String?,
              firstName: userId['first_name'] as String?,
              lastName: userId['last_name'] as String?,
              usersType: userId['role'] as int? ?? 0,
              picture: userId['profile_image'] as String?,
            )
          : null,
      itemsId: [],
    );

    return (
      selfie: selfie,
      linkedProducts: linkedProducts,
      similarProducts: similarProducts,
      brandCollections: brandCollections,
    );
  }

  Future<List<Map<String, dynamic>>> fetchBrandProducts(
    String brandId, {
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _client.get(
      ApiEndpoints.getProductsList,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage', 'brand_id': brandId},
    );
    final outer = response['data'] as Map<String, dynamic>? ?? {};
    return (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    final response = await _client.get(
      ApiEndpoints.getProductDetail(productId),
      requiresAuth: true,
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Autocomplete suggestions (creators + brands) for the given [search] text.
  Future<List<SuggestionModel>> getSuggestions(
    String search, {
    int page = 1,
    int perPage = 10,
  }) async {
    final query = search.trim();
    if (query.isEmpty) return [];
    final response = await _client.get(
      ApiEndpoints.getSuggestions,
      requiresAuth: true,
      queryParams: {'search': query, 'page': '$page', 'perPage': '$perPage'},
    );
    final raw = response['data'];
    final List<dynamic> list;
    if (raw is Map) {
      list = (raw['data'] as List<dynamic>?) ?? [];
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(SuggestionModel.fromJson)
        .where((s) => s.id.isNotEmpty && s.title.isNotEmpty)
        .toList();
  }

  // ─── Product like / unlike (keyed by variant id) ──────────────────────────

  Future<void> likeProduct(String variantId) {
    return _client.post(ApiEndpoints.likeProduct(variantId), requiresAuth: true);
  }

  Future<void> unlikeProduct(String variantId) {
    return _client.post(ApiEndpoints.unlikeProduct(variantId),
        requiresAuth: true);
  }

  /// Returns one page of the user's liked products for display.
  Future<({List<LikedProductModel> items, bool hasMore})> getLikedProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _client.get(
      ApiEndpoints.getLikedProducts,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    final outer = response['data'] as Map<String, dynamic>? ?? {};
    final list = (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LikedProductModel.fromJson)
        .where((m) => m.productId.isNotEmpty)
        .toList();
    final totalPages = (outer['totalPages'] as num?)?.toInt() ??
        (outer['total_pages'] as num?)?.toInt() ??
        page;
    return (items: list, hasMore: page < totalPages);
  }

  /// Returns the set of variant ids the current user has liked, so the UI can
  /// seed its heart state. Paginates until all liked products are collected.
  Future<Set<String>> getLikedVariantIds({int perPage = 50}) async {
    final ids = <String>{};
    var page = 1;
    while (true) {
      final response = await _client.get(
        ApiEndpoints.getLikedProducts,
        requiresAuth: true,
        queryParams: {'page': '$page', 'perPage': '$perPage'},
      );
      final outer = response['data'] as Map<String, dynamic>? ?? {};
      final list = (outer['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      for (final item in list) {
        final variant = item['variant_id'];
        final id = variant is Map
            ? (variant['_id']?.toString() ?? '')
            : (variant?.toString() ?? '');
        if (id.isNotEmpty) ids.add(id);
      }
      final totalPages = (outer['total_pages'] as num?)?.toInt() ??
          (outer['totalPages'] as num?)?.toInt() ??
          page;
      if (page >= totalPages || list.isEmpty) break;
      page++;
    }
    return ids;
  }

  Future<void> likeSelfie(String selfieId) {
    return _client.post(ApiEndpoints.likeSelfie(selfieId), requiresAuth: true);
  }

  Future<void> unlikeSelfie(String selfieId) {
    return _client.post(ApiEndpoints.unlikeSelfie(selfieId), requiresAuth: true);
  }
}
