// lib/webservices/profile_api.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class ProfileApi {
  static const String _baseUrl = 'https://newapi.happer.fr/api';

  //static const String _baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  /// Fetches Stripe configuration from the API
  /// This includes publishable key and other required Stripe settings
  Future<Map<String, dynamic>?> getStripeConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('...........................................................');
      print(token);
      print('...........................................................');

      if (token == null) {
        debugPrint('Token not found. User may need to log in.');
        return null;
      }

      final url = Uri.parse('$_baseUrl/carts/stripe');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, // Match the format used in stripe_api.dart (no "Bearer " prefix)
        },
        body: jsonEncode({
          'amount': 0, // We're just getting the config, not creating a payment
          'currency': 'usd',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save the publishable key to shared preferences for later use
        if (data['publishableKey'] != null) {
          await prefs.setString(
              'stripe_publishable_key', data['publishableKey']);

          // Update Stripe configuration immediately
          Stripe.publishableKey = data['publishableKey'];
          await Stripe.instance.applySettings();
        }

        return {
          'publishableKey': data['publishableKey'],
          'paymentIntent': data['paymentIntent'],
          'ephemeralKey': data['ephemeralKey'],
          'customer': data['customer'],
        };
      } else {
        debugPrint('Failed to fetch Stripe config: ${response.body}');
        debugPrint('Status code: ${response.statusCode}');
        return null;
      }
    } catch (e, s) {
      debugPrint('Error fetching Stripe config: $e');
      debugPrint('Error fetching Stripe config: $s');
      return null;
    }
  }

  /// Retrieves the stored Stripe publishable key
  /// Returns null if no key is stored
  static Future<String?> getStoredPublishableKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('stripe_publishable_key');
  }
}
