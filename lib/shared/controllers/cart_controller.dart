import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final cartItemCount = 0.obs;
  final previewImageUrls = <String>[].obs;
  final total = 0.0.obs;
  final subtotal = 0.0.obs;

  // variantId → cart item _id — used by ProductCard to restore "in cart" state
  final cartItemsByVariant = <String, String>{}.obs;

  bool isVariantInCart(String variantId) => cartItemsByVariant.containsKey(variantId);
  String? cartItemIdForVariant(String variantId) => cartItemsByVariant[variantId];

  void markVariantAdded(String variantId, String cartItemId) {
    cartItemsByVariant[variantId] = cartItemId;
  }

  void markVariantRemoved(String variantId) {
    cartItemsByVariant.remove(variantId);
  }

  Future<void> fetchCartItemCount() async {
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final data = await repo.getMyCart();
      if (data == null) {
        _reset();
        return;
      }
      final items = data['items'] as List<dynamic>? ?? [];
      cartItemCount.value = items.fold<int>(
        0,
        (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 1),
      );
      total.value = (data['total'] as num?)?.toDouble() ?? 0;
      subtotal.value = (data['subtotal'] as num?)?.toDouble() ?? total.value;

      // Build variantId → cartItemId map so ProductCard can restore its state
      final newMap = <String, String>{};
      for (final item in items) {
        final itemId = item['_id'] as String? ?? '';
        if (itemId.isEmpty) continue;
        final variantRaw = item['variant_id'];
        final variantId = variantRaw is Map
            ? (variantRaw['_id'] as String? ?? '')
            : (variantRaw as String? ?? '');
        if (variantId.isNotEmpty) newMap[variantId] = itemId;
      }
      cartItemsByVariant.value = newMap;

      final recent = items.length > 3 ? items.sublist(items.length - 3) : items;
      previewImageUrls.value = recent.map<String>((item) {
        final variantRaw = item['variant_id'];
        if (variantRaw is Map) {
          final imgs = (variantRaw['images'] as List?)
              ?.whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          if (imgs != null && imgs.isNotEmpty) return imgs.first;
        }
        final productRaw = item['product_id'];
        if (productRaw is Map) {
          return (productRaw['product_image'] as String? ?? '').trim();
        }
        return '';
      }).where((url) => url.isNotEmpty).toList();

      debugPrint('[CartController] count=${cartItemCount.value} variants=${cartItemsByVariant.keys.toList()}');
    } catch (e, st) {
      debugPrint('[CartController] error: $e\n$st');
      _reset();
    }
  }

  void clearCart() => _reset();

  void _reset() {
    cartItemCount.value = 0;
    previewImageUrls.value = [];
    total.value = 0;
    subtotal.value = 0;
    cartItemsByVariant.value = {};
  }
}
