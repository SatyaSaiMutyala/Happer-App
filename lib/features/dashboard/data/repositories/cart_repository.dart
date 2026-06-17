import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';

class CartRepository {
  final ApiClient _client;

  CartRepository(this._client);

  /// Returns the cart item _id of the newly added item, or null on failure.
  Future<String?> addToCart({
    required String productId,
    required String variantId,
    required String affiliateId,
    int quantity = 1,
  }) async {
    final response = await _client.post(
      ApiEndpoints.addToCart,
      requiresAuth: true,
      body: {
        'product_id': productId,
        'variant_id': variantId,
        'affiliate_id': affiliateId,
        'quantity': quantity,
      },
    );
    final items = (response['data']?['items'] as List<dynamic>?) ?? [];
    for (final item in items) {
      if (item is Map &&
          item['product_id']?.toString() == productId &&
          item['variant_id']?.toString() == variantId) {
        return item['_id']?.toString();
      }
    }
    return null;
  }

  /// Returns null when the cart is empty.
  Future<Map<String, dynamic>?> getMyCart() async {
    final response = await _client.get(
      ApiEndpoints.getMyCart,
      requiresAuth: true,
    );
    return response['data'] as Map<String, dynamic>?;
  }

  Future<void> removeCartItem(String itemId) async {
    await _client.delete(
      ApiEndpoints.removeCartItem(itemId),
      requiresAuth: true,
    );
  }

  /// Returns the payment URL (or full response) from the gateway.
  Future<Map<String, dynamic>> initiatePayment(String addressId) async {
    final response = await _client.post(
      ApiEndpoints.initiatePayment,
      requiresAuth: true,
      body: {'address_id': addressId},
    );
    return response['data'] as Map<String, dynamic>? ?? response;
  }
}
