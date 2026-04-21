import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happer_app/features/profile/models/code_credit_model.dart';
import 'package:happer_app/features/profile/models/promo_code_model.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodeCreditApiService {
    static const String baseUrl = 'https://newapi.happer.fr/api';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  Future<CodeCredit> getCodeCredits() async {
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
      // First get user info from user/me endpoint to fetch credit code and credits
      debugPrint('Fetching user data from /users/me endpoint');
      final userResponse = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': token!},
      );

      String? creditCode;
      int credits = 0;

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        debugPrint('User data response: $userData');

        // Get credit code from user data - this should be from credit_code field, not credits
        creditCode = userData['credit_code'] as String?;

        // Try to get credits directly from user data if available
        if (userData.containsKey('credits')) {
          credits = userData['credits'] ?? 0;
          debugPrint('Credits fetched directly from user data: $credits');
          return CodeCredit(credits: credits, code: creditCode);
        }

        debugPrint('Credit code fetched: $creditCode');
      } else {
        debugPrint('Failed to load user info: ${userResponse.statusCode}');
        debugPrint('Response: ${userResponse.body}');
      }

      // If credits not in user/me, fall back to promo_codes/me endpoint
      debugPrint('Fetching credits from promo_codes/me endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl/promo_codes/me'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Promo code response: $data');
        credits = data['credits'] ?? 0;
        debugPrint('Credits fetched from promo_codes: $credits');
        return CodeCredit(credits: credits, code: creditCode);
      } else {
        debugPrint('Failed to load code credits: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('Failed to load code credits');
      }
    } catch (e) {
      debugPrint('Error in getCodeCredits: $e');
      // For development purposes, return mock data if API is not ready
      throw Exception('Error fetching code credits: $e');
    }
  }

  // New function to specifically fetch user profile with promo code
  Future<Map<String, dynamic>?> fetchUserProfile() async {
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
        return null;
      }
    }

    try {
      // Get user info from user/me endpoint
      debugPrint('Fetching user profile from /users/me endpoint');
      final userResponse = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': token!},
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        debugPrint('User profile data response: $userData');
        return userData;
      } else {
        debugPrint('Failed to load user profile: ${userResponse.statusCode}');
        debugPrint('Response: ${userResponse.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
  
  // New function specifically for fetching promo code from promo_codes/me endpoint
  Future<String?> fetchPromoCode() async {
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
        return null;
      }
    }

    try {
      debugPrint('Fetching promo code from /promo_codes/me endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl/promo_codes/me'),
        headers: {'Authorization': token!},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Promo code response: $data');
        
        // Extract promo code from response - adjust field name if needed
        final promoCode = data['code'] as String?;
        debugPrint('Promo code fetched: $promoCode');
        return promoCode;
      } else {
        debugPrint('Failed to load promo code: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching promo code: $e');
      return null;
    }
  }

  Future<bool> verifyCode(String code) async {
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
      // Using PUT instead of POST as shown in the working curl example
      final response = await http.put(
        Uri.parse('$baseUrl/promo_codes/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': token!},
        body: jsonEncode({'code': code}),
      );

      debugPrint('Verify code response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error verifying code: $e');
      return false;
    }
  }
  
  // Fetch all promo codes for the current user
  Future<List<PromoCode>> fetchAllPromoCodes() async {
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
      debugPrint('Fetching all promo codes from /promo_codes/me endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl/promo_codes/me'),
        headers: {'Authorization': token!},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('Promo codes response: $data');
        
        // Convert the JSON data to PromoCode objects
        List<PromoCode> promoCodes = data.map((item) => PromoCode.fromJson(item)).toList();
        debugPrint('Fetched ${promoCodes.length} promo codes');
        
        return promoCodes;
      } else {
        debugPrint('Failed to load promo codes: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('Failed to load promo codes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching promo codes: $e');
      throw Exception('Error fetching promo codes: $e');
    }
  }
}
