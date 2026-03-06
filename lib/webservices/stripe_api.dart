import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StripeApi {
    static const String _baseUrl = 'https://newapi.happer.fr/api';

  //static const String _baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';
  static const String _apiVersion = '2025-03-31.basil';

  /// Get the authorization token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get common headers for API requests
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {'Authorization': token, 'Content-Type': 'application/json'};
  }

  /// Create a Stripe customer
  /// Returns the customer ID from the response
  static Future<String> createCustomer() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/carts/stripe/create-customer'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create customer: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final customerId = data['customerId'];

      if (customerId == null || customerId.isEmpty) {
        throw Exception('Invalid customer ID received from server');
      }

      debugPrint('Customer created with ID: $customerId');
      return customerId;
    } catch (e) {
      debugPrint('Error creating Stripe customer: $e');
      throw Exception('Error creating Stripe customer: $e');
    }
  }

  /// Create an ephemeral key for a customer
  /// Returns the ephemeral key secret
  static Future<String> createEphemeralKey(String customerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/carts/stripe/ephemeral-keys'),
        headers: headers,
        body: jsonEncode({
          'customer_id': customerId,
          'api_version': _apiVersion,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create ephemeral key: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final secret = data['secret'];

      if (secret == null || !secret.toString().startsWith('ek_')) {
        throw Exception('Invalid ephemeral key secret received');
      }

      return secret;
    } catch (e) {
      debugPrint('Error creating ephemeral key: $e');
      throw Exception('Error creating ephemeral key: $e');
    }
  }

  /// Create a payment intent
  /// Returns a map containing paymentIntent (client secret), customer, publishableKey, and ephemeralKey
  static Future<Map<String, String>> createPaymentIntent(
    String customerId,
    int amount,
  ) async {
    try {
      // First create an ephemeral key
      final ephemeralKey = await createEphemeralKey(customerId);

      final headers = await _getHeaders();
      final requestBody = {
        'api_version': _apiVersion,
        'customer_id': customerId,
        'amount': amount,
        'currency': 'eur',
        // Don't restrict payment methods - let Stripe automatically enable card, Google Pay, Apple Pay, etc.
        // Klarna can be enabled in Stripe Dashboard if needed
        // 'payment_method_types[]': ['card', 'klarna'],
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/carts/stripe'),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      debugPrint('=== BACKEND PAYMENT INTENT DEBUG ===');
      debugPrint('=== checking for amount === $amount');
debugPrint('Requested payment_method_types: AUTO (not restricted - enables all supported methods)');
debugPrint('Stripe Response: $response');
debugPrint('===================================');

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
      // Note: Google Pay and Apple Pay are automatically enabled through the Payment Sheet
      // configuration when 'card' payment method is available. No need to explicitly
      // include them in payment_method_types.

      final responseData = jsonDecode(response.body);
      debugPrint('Stripe create payment intent response: $responseData');

      // CRITICAL: Log the actual response body to see backend configuration
      debugPrint('=== FULL BACKEND RESPONSE ===');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Status: ${response.statusCode}');

      // Validate backend is using automatic_payment_methods correctly
      if (responseData['message']?.toString().contains('automatic_payment_methods') == true) {
        debugPrint('✅ Backend is using automatic_payment_methods');
      } else {
        debugPrint('⚠️ WARNING: Cannot confirm if backend is using automatic_payment_methods');
        debugPrint('⚠️ If Google Pay does not appear, backend may be restricting payment_method_types');
      }
      debugPrint('============================');

      // Validate required fields
      final paymentIntent = responseData['paymentIntent'];
      final publishableKey = responseData['publishableKey'];

      if (paymentIntent == null || !paymentIntent.toString().contains('_secret_')) {
        throw Exception('Invalid payment intent received');
      }

      if (publishableKey == null || !publishableKey.toString().startsWith('pk_')) {
        throw Exception('Invalid publishable key received');
      }

      // Return all required fields for the payment flow
      return {
        'paymentIntent': paymentIntent,
        'ephemeralKey': ephemeralKey,
        'publishableKey': publishableKey,
        'customer': customerId,
      };
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      throw Exception('Error creating payment intent: $e');
    }
  }
}