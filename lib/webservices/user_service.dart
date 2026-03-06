import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserService {
    static const String baseUrl = 'https://newapi.happer.fr/api';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';
  
  /// Fetches the user's credits from the API
  Future<int> fetchUserCredits() async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token not found or invalid');
        return 0;
      }

      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.get(
        url,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final credits = data['credits'] as int? ?? 0;
        debugPrint('User credits fetched successfully: $credits');
        return credits;
      } else if (response.statusCode == 401) {
        // Token might be expired, try to refresh it
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Try again with the new token
          return fetchUserCredits();
        } else {
          debugPrint('Failed to refresh token');
          return 0;
        }
      } else {
        debugPrint('Failed to fetch user credits: ${response.statusCode} - ${response.body}');
        return 0;
      }
    } catch (e) {
      debugPrint('Error fetching user credits: $e');
      return 0;
    }
  }

  /// Fetches the user's profile from the API
  Future<Map<String, dynamic>?> fetchUserProfile({bool forceRefresh = false}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token not found or invalid');
        return null;
      }

      // Base URL with optional cache-busting parameter
      var urlString = '$baseUrl/users/me';
      if (forceRefresh) {
        urlString += '?_t=${DateTime.now().millisecondsSinceEpoch}';
      }
      
      final url = Uri.parse(urlString);
      
      // Set cache-control header to prevent caching
      final headers = {
        'Authorization': token,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      };
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('User profile fetched successfully');
        return data;
      } else if (response.statusCode == 401) {
        // Token might be expired, try to refresh it
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Try again with the new token
          return fetchUserProfile();
        } else {
          debugPrint('Failed to refresh token');
          return null;
        }
      } else {
        debugPrint('Failed to fetch user profile: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Gets a valid token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null || token.isEmpty) {
      return null;
    }
    
    return token;
  }

  /// Refreshes the token if it's expired
  Future<bool> _refreshToken() async {
    final authService = AuthService();
    return await authService.refreshToken();
  }
}