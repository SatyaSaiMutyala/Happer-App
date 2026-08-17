import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/order_log_model.dart';
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

  /// The fulfilment timeline for one line item, oldest entry first — what the
  /// order detail screen's tracker is built from.
  ///
  /// Returns an empty list when the order has no logs yet: orders paid before
  /// the backend started writing them carry none, and the tracker has to fall
  /// back to the item's plain status in that case.
  Future<List<OrderLog>> getOrderLogs({
    required String orderId,
    required String cartItemId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.orderLogs(orderId, cartItemId),
      requiresAuth: true,
    );
    return (response['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderLog.fromJson)
        .toList();
  }

  /// Cancels a single line item. [orderId] is the purchase's `order_id` (the
  /// cart id) and [cartItemId] its `cart_item_id`.
  ///
  /// Only call this for an item whose [PurchasedProduct.isCancellable] is true —
  /// the backend re-checks and rejects anything already delivered or cancelled.
  Future<void> cancelOrder({
    required String orderId,
    required String cartItemId,
    String? reason,
  }) async {
    await _client.post(
      ApiEndpoints.cancelOrder,
      requiresAuth: true,
      body: {
        'cart_id': orderId,
        'item_id': cartItemId,
        if (reason != null && reason.trim().isNotEmpty)
          'cancel_reason': reason.trim(),
      },
    );
  }
}
