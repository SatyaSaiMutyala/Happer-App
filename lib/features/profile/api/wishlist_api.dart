// lib/profile/api/wishlist_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/wishlist_model.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistApiService {
    static const String baseUrl = 'https://newapi.happer.fr/api';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  Future<List<WishlistItem>> getWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      debugPrint('Token is null or expired. Attempting to refresh.');
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
        debugPrint('Token refreshed successfully: $token');
      } else {
        debugPrint('Failed to refresh token.');
        throw Exception('Failed to refresh token');
      }
    }

    try {
      debugPrint('Fetching wishlist items with token: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/wishes/me'),
        headers: {
          'Authorization': token!,
        },
      );

      debugPrint('Wishlist response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => WishlistItem.fromJson(item)).toList();
      } else {
        debugPrint('Failed to load wishlist: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('Failed to load wishlist items');
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
      // For development purposes, return mock data if API is not ready
      return _getMockWishlistItems();
    }
  }

  Future<bool> addToWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      debugPrint('Token is null or expired. Attempting to refresh.');
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
      } else {
        return false;
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wishlist/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      return false;
    }
  }

  Future<bool> removeFromWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      debugPrint('Token is null or expired. Attempting to refresh.');
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
      } else {
        return false;
      }
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/wishlist/remove/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return false;
    }
  }

  // Mock data for development
  List<WishlistItem> _getMockWishlistItems() {
    return [
      WishlistItem(
        id: '68239446a29271d17739e831',
        userId: '681bae890844b9475bcf127f',
        createdAt: '2025-05-14T01:13:55.561Z',
        productId: '64a2993a534d42fa71b38738',
        title: 'Bottines en daim et en cuir Daphne',
        brand: 'DIANE VON FURSTENBERG',
        description: {'en': 'Beautiful boots made of suede and leather', 'fr': 'Belles bottes en daim et cuir'},
        price: 789.00,
        discountPercentage: 55,
        pictures: ['https://picturehappertest.blob.core.windows.net/1926545033358107-64a2993a534d42fa71b38738/6134026632239378-Captured\'écran2023-04-14173543.png'],
        startDate: '2023-06-26T07:53:00.000Z',
        endDate: '2023-07-02T07:53:00.000Z',
        timer: '1747235030305',
        timerStamp: 30,
      ),
      WishlistItem(
        id: '68239425a29271d17739e830',
        userId: '681bae890844b9475bcf127f',
        createdAt: '2025-05-14T01:39:07.958Z',
        productId: '678d1722c4cc2952781c2c63',
        title: 'Escarpins en cuir verni Romy 100',
        brand: 'JIMMY CHOO',
        description: {'en': 'Elegant patent leather pumps', 'fr': 'Élégants escarpins en cuir verni'},
        price: 495.99,
        discountPercentage: 50,
        pictures: ['https://picturehappertest.blob.core.windows.net/some-container/some-image.png'],
        startDate: '2022-12-04T10:29:26.693Z',
        endDate: '2029-12-19T10:29:26.693Z',
        timer: '1747235030305',
        timerStamp: 30,
      ),
    ];
  }
}
