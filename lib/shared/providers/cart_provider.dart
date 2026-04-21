import 'package:flutter/material.dart';
import 'package:happer_app/features/creator/api/cart_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  int _cartItemCount = 0;

  int get cartItemCount => _cartItemCount;

  /// Fetch cart item count from API
  Future<void> fetchCartItemCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      _cartItemCount = 0;
      notifyListeners();
      return;
    }

    final cartApi = CartApi(token: token);

    try {
      final cartModel = await cartApi.getCartDetails();
      _cartItemCount = cartModel.data?.items?.length ?? 0;

      debugPrint('................................');
      debugPrint('Cart item count updated: $_cartItemCount');
      debugPrint('................................');

      notifyListeners();
    } catch (e, s) {
      debugPrint('Error fetching cart item count: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  
}
