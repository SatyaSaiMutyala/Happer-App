import 'dart:convert';

import 'package:happer_app/creator/model/address_model.dart' as address_model;
import 'package:happer_app/creator/model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartApi {
  static const String baseUrl = 'https://newapi.happer.fr/';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/';
  final String token;

  CartApi({required this.token});

  Future<void> addToCart({
    required String itemId,
    required int quantity,
    required String size,
    required String userId,
  }) async {
    print('CART API: Starting addToCart request');
    print(
      'CART API: Parameters - itemId: $itemId, quantity: $quantity, size: $size, userId: $userId',
    );

    if (token.isEmpty || JwtDecoder.isExpired(token)) {
      print('CART API ERROR: Token is missing or expired');
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/add');
    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };

    final requestBody = [
      {
        'item_id': itemId,
        'quantity': quantity,
        'size': size,
        'user_id': userId,
      },
    ];

    final body = jsonEncode(requestBody);

    print('CART API REQUEST: URL=${url.toString()}');
    print('CART API REQUEST: Headers=$headers');
    print('CART API REQUEST: Body=$body');

    try {
      print('CART API: Sending POST request...');
      final response = await http.post(url, headers: headers, body: body);

      print('CART API RESPONSE: Status=${response.statusCode}');
      print('CART API RESPONSE: Body=${response.body}');

      if (response.statusCode == 200) {
        print('CART API SUCCESS: Item successfully added to cart');
        try {
          final responseData = jsonDecode(response.body);
          print('CART API SUCCESS: Response data=$responseData');
        } catch (e) {
          print('CART API WARNING: Could not parse response body as JSON: $e');
        }
      } else if (response.statusCode == 400) {
        print('CART API ERROR 400: Bad request');
        throw Exception('Failed to add item to cart: ${response.body}');
      } else if (response.statusCode == 401) {
        print('CART API ERROR 401: Authentication failed');
        throw Exception('Authentication failed: ${response.body}');
      } else {
        print('CART API ERROR ${response.statusCode}: Unexpected status code');
        throw Exception('Unexpected error: ${response.body}');
      }
    } catch (e) {
      print('CART API EXCEPTION: Error adding item to cart: ${e.toString()}');
      throw Exception('Error adding item to cart: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getCartMe() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      // Add token refresh logic here if needed
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/me');
    final headers = {'Authorization': '$token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch cart details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching cart details');
    }
  }

  Future<CartModel> getCartDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      print('DEBUG: Token is missing or expired');
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/me');
    final headers = {'Authorization': '$token'};

    try {
      print('DEBUG: Sending GET request to $url with headers $headers');
      final response = await http.get(url, headers: headers);
      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Parsed cart data: $data');
        return CartModel.fromJson(data);
      } else {
        print('DEBUG: Failed to fetch cart details: ${response.body}');
        throw Exception('Failed to fetch cart details: ${response.body}');
      }
    } catch (e,s) {
      print('DEBUG: Exception occurred while fetching cart details: $e');
      print( s);
      throw Exception('Error fetching cart details');
    }
  }

  Future<bool> deleteCartItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      // Add token refresh logic here if needed
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/item');
    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'item_id': itemId});

    try {
      final response = await http.delete(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error deleting item from cart');
    }
  }

  Future<void> getAllMyCarts() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      // Add token refresh logic here if needed
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/me/all');
    final headers = {'Authorization': 'Token $token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to fetch all carts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching all carts');
    }
  }

  Future<address_model.AddressModel> updateCartAddresses({
    required String id,
    required address_model.ShippingAddress billingAddress,
    required address_model.ShippingAddress shippingAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      throw Exception('Token is missing or expired');
    }

    final url = Uri.parse('${baseUrl}api/carts/addresses');
    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'id': id,
      'billing_address': billingAddress.toJson(),
      'shipping_address': shippingAddress.toJson(),
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return address_model.AddressModel.fromJson(data);
      } else {
        throw Exception('Failed to update cart addresses: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating cart addresses');
    }
  }
}
