import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductApi {
    static const String _baseUrl = 'https://newapi.happer.fr/api';

  //static const String _baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  /// Happ a product
  /// Returns a Map with success status and message
  static Future<Map<String, dynamic>> happProduct(String productId) async {
    try {
      debugPrint('Attempting to happ product with ID: $productId');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No authentication token found');
        return {'success': false, 'message': 'Authentication token not found'};
      }

      final response = await http.post(
        Uri.parse('https://newapi.happer.fr/api/products/$productId/happ'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Happ API Response Status: ${response.statusCode}');
      debugPrint('Happ API Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Check for server error message in 200 response (happens when already happed)
        final containsErrorMessage = 
            (response.body.contains('error') || 
             response.body.contains('server error') || 
             responseData['message'] == 'Server error occurred');
            
        return {
          'success': !containsErrorMessage,
          'message': containsErrorMessage 
              ? 'Server error occurred' 
              : (response.body.trim().toString().isNotEmpty ? response.body.trim().toString() : 'Product happed successfully'),
          'statusCode': 200,
        };
      } else if (response.statusCode == 500) {
        // For 500 errors, try to extract the specific error message
        final errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            'Server error occurred';
        return {'success': false, 'message': errorMessage, 'statusCode': 500};
      } else {
        return {
          'success': false,
          'message':
              'Failed to happ product: ${responseData['message'] ?? response.body.trim().toString()}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('Error happing product: $e');
      return {
        'success': false,
        'message': 'Error occurred while happing product',
        'statusCode': 0, // Special status code for client-side errors
      };
    }
  }
}
