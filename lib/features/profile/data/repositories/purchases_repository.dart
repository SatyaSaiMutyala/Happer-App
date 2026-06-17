import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/purchase_model.dart';

class PurchasesRepository {
  final _client = ApiClient();

  Future<List<PurchasedProduct>> getPurchasedProducts({
    required int page,
    required int perPage,
  }) async {
    final response = await _client.get(
      ApiEndpoints.getPurchasedProducts,
      requiresAuth: true,
      queryParams: {'page': '$page', 'perPage': '$perPage'},
    );
    final outer = response['data'] as Map<String, dynamic>? ?? {};
    return (outer['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PurchasedProduct.fromJson)
        .toList();
  }
}
