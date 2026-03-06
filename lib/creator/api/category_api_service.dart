import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../camera/model/category_model.dart';

class CategoryApiService {
    static const String baseUrl = 'https://newapi.happer.fr';

  //final String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com';

  Future<List<Category>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      
      return [];
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/categories/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
    
      return null;
    }
  }
}