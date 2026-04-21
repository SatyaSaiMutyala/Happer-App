import 'dart:convert';

import 'package:happer_app/features/discover/models/discover_model.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoverApiService {
    static const String baseUrl = 'https://newapi.happer.fr/';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/';
  final String token;
  
  DiscoverApiService({required this.token});

   Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
      } else {
        throw Exception('Failed to refresh token');
      }
    }

    return token!;
  }
  
  Future<List<DiscoverModel>> fetchDiscoverSelfies({
    required String categoryId,
    required int page,
    required String country,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null || JwtDecoder.isExpired(token)) {
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
      } else {
        throw Exception('Failed to refresh token');
      }
    } 
    
    final url = Uri.parse('${baseUrl}api/selfies?page=$page');
    
    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => DiscoverModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load selfies: ${response.statusCode}');
    }
  }

Future<dynamic> fetchDiscoverSelfieDetails(String selfieId) async {
    final token = await _getValidToken();

    final url = Uri.parse('${baseUrl}api/selfies/$selfieId');

    final response = await http.get(url, headers: {'Authorization': token});

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
        throw Exception('Failed to parse response');
      }
    } else {
      throw Exception('Failed to load selfie details');
    }
  }


}
