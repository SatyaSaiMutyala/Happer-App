import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/selfies/data/models/selfie_model.dart';

class SelfieRepository {
  final ApiClient _client;

  SelfieRepository(this._client);

  Future<List<SelfieModel>> getSelfies({int page = 1, int limit = 15}) async {
    final response = await _client.get(
      ApiEndpoints.getSelfies,
      requiresAuth: true,
      queryParams: {'page': '$page', 'limit': '$limit'},
    );
    final data = response['data'] as List<dynamic>? ?? response['selfies'] as List<dynamic>? ?? [];
    return data.map((e) => SelfieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SelfieModel>> getOwnSelfies({int page = 1, int perPage = 15}) async {
    final response = await _client.get(
      ApiEndpoints.getOwnSelfies,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    // Handle: { data: { selfies: [...] } } or { data: [...] } or { selfies: [...] }
    final raw = response['data'];
    List<dynamic> list = [];
    if (raw is Map) {
      list = raw['selfies'] as List<dynamic>? ?? raw['data'] as List<dynamic>? ?? [];
    } else if (raw is List) {
      list = raw;
    } else {
      list = response['selfies'] as List<dynamic>? ?? [];
    }
    return list.map((e) => SelfieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SelfieModel>> getNormalUserSelfies({int page = 1, int perPage = 10}) async {
    final response = await _client.get(
      ApiEndpoints.getNormalUserSelfies,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    final outer = response['data'] as Map<String, dynamic>? ?? {};
    final list = outer['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SelfieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SelfieModel> getSelfieDetail(String id) async {
    final response = await _client.get(
      ApiEndpoints.getSelfieDetail(id),
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return SelfieModel.fromJson(data);
  }

  Future<void> deleteSelfie(String id) async {
    await _client.delete(
      ApiEndpoints.deleteSelfie(id),
      requiresAuth: true,
    );
  }

  Future<void> submitSelfie(List<String> imageUrls, {List<Map<String, dynamic>> linkedProducts = const []}) async {
    final body = <String, dynamic>{'images': imageUrls};
    if (linkedProducts.isNotEmpty) body['linked_products'] = linkedProducts;
    await _client.post(
      ApiEndpoints.submitSelfie,
      requiresAuth: true,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> getProductsList({int page = 1, int perPage = 100}) async {
    final response = await _client.get(
      ApiEndpoints.getLinkedProducts,
      requiresAuth: true,
      queryParams: {'page': page.toString(), 'perPage': perPage.toString()},
    );
    final outer = (response['data'] as Map<String, dynamic>?) ?? {};
    final items = (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty) return items;

    // get-linked-products doesn't return product_image or variants,
    // so concurrently fetch full product detail for each to get images.
    final enriched = await Future.wait(
      items.map((item) async {
        final id = item['_id'] as String?;
        if (id == null || id.isEmpty) return item;
        try {
          final detail = await _client.get(
            ApiEndpoints.getProductDetail(id),
            requiresAuth: true,
          );
          final data = detail['data'] as Map<String, dynamic>? ?? {};
          return <String, dynamic>{...item, ...data};
        } catch (_) {
          return item;
        }
      }),
    );

    return enriched;
  }

  Future<String> uploadSelfieImage(String filePath) async {
    final response = await _client.multipart(
      ApiEndpoints.fileUpload,
      method: 'POST',
      filePaths: {'file': filePath},
      requiresAuth: true,
    );
    // Response can be: { data: "url" } or { data: { url: "..." } } or { url: "..." }
    final data = response['data'];
    if (data is String) return data;
    if (data is Map) return data['url'] as String? ?? '';
    return response['url'] as String? ?? '';
  }

  Future<SelfieUser> getCurrentUser() async {
    final response = await _client.get(
      ApiEndpoints.fetchProfile,
      requiresAuth: true,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return SelfieUser.fromJson(data);
  }

  Future<void> likeSelfie(String id) async {
    await _client.post(
      ApiEndpoints.likeSelfie(id),
      requiresAuth: true,
    );
  }

  Future<void> unlikeSelfie(String id) async {
    await _client.post(
      ApiEndpoints.unlikeSelfie(id),
      requiresAuth: true,
    );
  }
}
