import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMTestService {
  static Future<bool> sendTestNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Replace with your server key from Firebase Console -> Project Settings -> Cloud Messaging
      const String serverKey = 'YOUR_SERVER_KEY';
      
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'sound': 'default',
              'badge': '1',
            },
            'priority': 'high',
            'data': data ?? <String, dynamic>{},
            'to': token,
          },
        ),
      );

     
      return response.statusCode == 200;
    } catch (e) {
  
      return false;
    }
  }
}
