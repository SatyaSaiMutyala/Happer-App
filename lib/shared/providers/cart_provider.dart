import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';

class CartProvider with ChangeNotifier {
  int _cartItemCount = 0;
  List<String> _previewImageUrls = [];
  double _total = 0;
  double _subtotal = 0;

  int get cartItemCount => _cartItemCount;
  List<String> get previewImageUrls => _previewImageUrls;
  double get total => _total;
  double get subtotal => _subtotal;

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
      _cartItemCount = items.length;
      _total = (data['total'] as num?)?.toDouble() ?? 0;
      _subtotal = (data['subtotal'] as num?)?.toDouble() ?? _total;

      // Last 3 items are the most recently added
      final recent = items.length > 3 ? items.sublist(items.length - 3) : items;
      _previewImageUrls = recent.map<String>((item) {
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

      debugPrint('[CartProvider] count=$_cartItemCount total=$_total');
      notifyListeners();
    } catch (e, st) {
      debugPrint('[CartProvider] fetchCartItemCount error: $e\n$st');
      _reset();
    }
  }

  void _reset() {
    _cartItemCount = 0;
    _previewImageUrls = [];
    _total = 0;
    _subtotal = 0;
    notifyListeners();
  }
}
