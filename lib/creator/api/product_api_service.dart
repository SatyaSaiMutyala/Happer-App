import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../camera/model/product_model.dart';

class ProductApiService {
  final String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com';

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/categories/$categoryId/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
    
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      
      return null;
    }
  }
}