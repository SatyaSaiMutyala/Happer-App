import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/won_product_model.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WonProductsApiService {
    static const String baseUrl = 'https://newapi.happer.fr/api';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  Future<List<WonProduct>> getWonProducts() async {
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
      final response = await http.get(
        Uri.parse('$baseUrl/products/win'),
        headers: {
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => WonProduct.fromJson(item)).toList();
      } else {
        debugPrint('Failed to load won products: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('Failed to load won products');
      }
    } catch (e) {
  
      debugPrint('Error: $e');
      throw Exception('An error occurred while fetching won products');
      
    }
  }

  // Mock data for development that matches the actual API response structure
  List<WonProduct> _getMockWonProducts() {
    return [
      WonProduct(
        id: '6823968aa29271d17739e835',
        brand: 'DIANE VON FURSTENBERG',
        brandId: '613e44ce1dec8457ecff1eda',
        title: 'Bottines en daim et en cuir Daphne',
        description: {
          'fr': 'Bottines élégantes en daim et cuir',
          'en': 'Elegant suede and leather boots'
        },
        priceOriginal: 789.00,
        pricePromo: 359.00,
        pictures: ['https://example.com/image1.jpg'],
        winnerName: 'Cindy P.',
        winnerId: '642860dbb883b5087acac82e',
        winAt: DateTime.now().subtract(Duration(days: 1)),
        startDate: DateTime.now().subtract(Duration(days: 2)),
        endDate: DateTime.now().add(Duration(days: 14)),
        timer: '1715673893429',
        timerStamp: null,
        happed: true,
        buyUrl: '',
        promoCodeWinner: '',
        state: 3,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      WonProduct(
        id: '6823968aa29271d17739e836',
        brand: 'JIMMY CHOO',
        brandId: '613e44ce1dec8457ecff1edb',
        title: 'Escarpins en cuir verni Romy 100',
        description: {
          'fr': 'Escarpins élégants en cuir verni',
          'en': 'Elegant patent leather pumps'
        },
        priceOriginal: 495.99,
        pricePromo: 249.00,
        pictures: ['https://example.com/image2.jpg'],
        winnerName: 'Cindy P.',
        winnerId: '642860dbb883b5087acac82e',
        winAt: DateTime.now().subtract(Duration(days: 3)),
        startDate: DateTime.now().subtract(Duration(days: 5)),
        endDate: DateTime.now().add(Duration(days: 10)),
        timer: '1715673893430',
        timerStamp: null,
        happed: true,
        buyUrl: '',
        promoCodeWinner: '',
        state: 3,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        updatedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }
}
