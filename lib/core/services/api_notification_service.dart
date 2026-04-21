import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiNotificationService {
  static final ApiNotificationService _instance = ApiNotificationService._internal();
  
  factory ApiNotificationService() {
    return _instance;
  }
  
  ApiNotificationService._internal();
  
  // Base URL for the API
    static const String _baseUrl = 'https://newapi.happer.fr/api';

  //final String _baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';
  
  // Get the auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Send a test notification through your backend API
  Future<Map<String, dynamic>?> sendTestNotification({
    required String title,
    required String body,
    String? userId,
    String type = 'Sample_Testing',
    List<String>? tokens,
  }) async {
    try {
      final token = await _getAuthToken();
      
      if (token == null) {
       
        return null;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'parameter': ['Sample'],
          'user_id': userId ?? '', // Use provided userId or empty string
          'type': type,
          'message': {
            'notification': {
              'title': title,
              'body': body,
            },
            'android': {
              'notification': {
                'sound': 'default'
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default'
                }
              }
            },
            'tokens': tokens ?? [] // Use provided tokens or empty array
          }
        }),
      );
  
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
  
        return null;
      }
    } catch (e) {
   
      return null;
    }
  }
  
  // Get all notifications for the current user
  Future<List<Map<String, dynamic>>?> getUserNotifications() async {
    try {
      final token = await _getAuthToken();
      
      if (token == null) {
     
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/user'),
        headers: {
          'Authorization': token,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
      
        return null;
      }
    } catch (e) {
    
      return null;
    }
  }
  
  // Get a specific notification by ID
  Future<Map<String, dynamic>?> getNotificationById(String notificationId) async {
    try {
      final token = await _getAuthToken();
      
      if (token == null) {
     
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': token,
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
     
        return null;
      }
    } catch (e) {
  
      return null;
    }
  }
}
