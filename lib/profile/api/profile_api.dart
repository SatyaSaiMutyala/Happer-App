import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happer_app/dashboard/models/notification_model.dart';
import 'package:happer_app/login_screen.dart';
import 'package:happer_app/profile/model/purchase_model.dart';
import 'package:happer_app/register_screen.dart';
import 'package:happer_app/webservices/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApiService {
    static const String baseUrl = 'https://newapi.happer.fr/';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/';

  final _prefs = SharedPreferences.getInstance();

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString('myId');
  }

  Future<bool> updateUserProfile(
    Map<String, dynamic> userData,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return false;
    }

    final url = Uri.parse('${baseUrl}api/users/$userId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
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

    final url = Uri.parse('${baseUrl}api/users/profile/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('USER PROFILELLE: ${response.body}');

      // Save the user ID for later use if needed
      prefs.setString('myId', data['_id'] ?? '');

      return data;
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUserProfile() async {
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

    final url = Uri.parse('${baseUrl}api/users/me');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
       print('MY PROFILELLE: ${response.body}');
       await prefs.setString('myUserId', data['_id'] ?? '');

      return data;
    } else {
      throw Exception('Failed to load current user profile');
    }
  }

  Future<int> followersByUserId(String userId) async {
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

    final url = Uri.parse('${baseUrl}api/follows/user/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['follows'] ?? 0;
    } else {
      throw Exception('Failed to load followers count');
    }
  }

  Future<void> followUser(String userId, String followerId) async {
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

    final url = Uri.parse('${baseUrl}api/follows');

    final response = await http.post(
      url,
      headers: {
        'Authorization': token ?? '',
        'Content-Type': 'application/json',
      },
      body: json.encode({'user_id': userId, 'follower_id': followerId}),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to follow user');
    }
  }

  Future<void> unfollowUser(String targetId) async {
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

    final url = Uri.parse('${baseUrl}api/follows/user');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': token ?? '',
        'Content-Type': 'application/json',
      },
      body: json.encode({'target_id': targetId}),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to unfollow user');
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      return;
    }

    final url = Uri.parse('${baseUrl}api/users/logout');

    final response = await http.post(url, headers: {'Authorization': token});

    if (response.statusCode == 200) {
      await prefs.remove('token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      throw Exception('Failed to logout');
    }
  }

  Future<List<dynamic>> fetchLikedSelfies() async {
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

    final url = Uri.parse('${baseUrl}api/selfies/liked');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data; // return full selfie objects
    } else {
      throw Exception('Failed to fetch liked selfies');
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
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

    final url = Uri.parse('${baseUrl}api/notifications/user');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      print('notificationResponse:: ${response.body.toString()}');
      List<NotificationModel> parseNotifications(String jsonString) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      return parseNotifications(response.body);
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
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

    final url = Uri.parse('${baseUrl}api/notifications/$notificationId/read');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<Datum>> fetchUserPurchases() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  // Refresh token if expired
  if (token == null || JwtDecoder.isExpired(token)) {
    final authService = AuthService();
    final refreshed = await authService.refreshToken();
    if (refreshed) {
      token = prefs.getString('token');
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  final url = Uri.parse('${baseUrl}api/carts/me/all');

  final response = await http.get(
    url,
    headers: {'Authorization': token ?? ''},
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    // Parse the full response into a Purchase object
    final purchase = Purchase.fromJson(decoded);

    // Return the flattened list of Datum (orders)
    return purchase.data ?? [];
  } else {
    throw Exception(
        'Failed to fetch purchases: ${response.statusCode} - ${response.body}');
  }
}

  // New method to fetch user selfies specifically
  Future<List<dynamic>> fetchUserSelfies(String userId) async {
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

    final url = Uri.parse('${baseUrl}api/selfies/user/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('selfies')) {
        return data['selfies'] as List;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<dynamic>> fetchUserProfileSelfies(String userId) async {
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

  List<dynamic> allSelfies = [];
  int page = 0;
  bool hasMore = true;

  while (hasMore) {
    final url = Uri.parse('${baseUrl}api/selfies/profile/$userId?page=$page');
    print('URLLL:$url');

    final response = await http.get(
      url,
      headers: {'Authorization': token ?? ''},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> selfies;
      if (data is List) {
        selfies = data;
      } else if (data is Map && data.containsKey('selfies')) {
        selfies = data['selfies'] as List;
      } else {
        selfies = [];
      }

      if (selfies.isEmpty) {
        hasMore = false;
      } else {
        allSelfies.addAll(selfies);
        page++;
      }
    } else {
      hasMore = false;
    }
  }

  return allSelfies;
}

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      debugPrint('Token is null or expired. Attempting to refresh.');
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
        debugPrint('Token refreshed successfully');
      } else {
        debugPrint('Failed to refresh token.');
        return {'success': false, 'message': 'Authentication failed'};
      }
    }

    try {
      final response = await http.put(
        Uri.parse('${baseUrl}api/users/modify_password'),
        headers: {'Content-Type': 'application/json', 'Authorization': token!},
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      debugPrint('Change password response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update password',
        };
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> changeYourPassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      debugPrint('Token is null or expired. Attempting to refresh.');
      final authService = AuthService();
      final refreshed = await authService.refreshToken();
      if (refreshed) {
        token = prefs.getString('token');
        debugPrint('Token refreshed successfully');
      } else {
        debugPrint('Failed to refresh token.');
        return {'success': false, 'message': 'Authentication failed'};
      }
    }

    try {
      final response = await http.put(
        Uri.parse('${baseUrl}api/users/modify_password'),
        headers: {'Content-Type': 'application/json', 'Authorization': token!},
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      debugPrint('Change password response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update password',
        };
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> initiateDeleteAccount(
    String userId,
    BuildContext context,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || userId.isEmpty) {
        throw Exception('Authentication token or user ID missing.');
      }

      final url = Uri.parse(
        '${baseUrl}api/users/$userId/delete_procedure',
      );

      debugPrint('=== DELETE ACCOUNT: initiateDeleteAccount ===');
      debugPrint('URL: $url');
      debugPrint('UserId: $userId');

      final response = await http.get(url, headers: {'Authorization': token});

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          final code = data['code']?.toString() ?? '';
          final createdAt = data['created_at'];
          debugPrint('SUCCESS: Received verification code: $code');
          debugPrint('Code created at: $createdAt');
          await prefs.setString('delete_verification_code', code);
        } else {
          debugPrint('SUCCESS: 200 OK - verification email sent');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email.'),
          ),
        );
      } else {
        debugPrint('FAILED: Status ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to initiate delete procedure: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('ERROR in initiateDeleteAccount: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteAccount(
    BuildContext context,
    String verificationCode,
  ) async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      debugPrint('Token44: $token');
    debugPrint('User ID44: $userId');


      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('${baseUrl}api/users/$userId');
      final body = jsonEncode({'code': verificationCode});

      debugPrint('=== DELETE ACCOUNT: deleteAccount ===');
      debugPrint('URL: $url');
      debugPrint('UserId: $userId');
      debugPrint('Code: $verificationCode');

      final response = await http.delete(
        url,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

   if (response.statusCode == 200) {
  try {
    final Map<String, dynamic> data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message'] ?? 'Account deleted successfully'),
      ),
    );
  } catch (e) {
    debugPrint('Error parsing response: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted successfully')),
    );
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
       debugPrint('Error in deleteAccount: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
      rethrow;
    }
  }

  Future<bool> deleteMyImage() async {
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

    final url = Uri.parse('${baseUrl}api/users/picture/delete');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('DELETE RESP:${response.body}');
        return true;
      } else {
        debugPrint(
          'Delete image failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in deleteMyImage: $e');
      return false;
    }
  }


Future<bool> deleteImageAPI(String selfieId) async {
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

    final url = Uri.parse('${baseUrl}/api/selfies/users/$selfieId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('DELETE RESP:${response.body}');
        return true;
      } else {
        debugPrint(
          'Delete image failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in deleteMyImage: $e');
      return false;
    }
  }

  // Notification settings methods
  Future<Map<String, dynamic>> fetchNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('${baseUrl}api/options/me');
    try {
      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch notification settings');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateNotificationSettings({
    required bool wishlist,
    required bool credits,
    required bool push,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('${baseUrl}api/options/me');
    final body = {'wishlist': wishlist, 'credits': credits, 'push': push};

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update notification settings');
      }
    } catch (e) {
      rethrow;
    }
  }
 
  Future<void> deleteNotification(String id, String accessToken) async {
    final url = Uri.parse('https://happer-production.francecentral.cloudapp.azure.com/api/notifications/user');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: '{"id":"$id"}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
    else if(response.statusCode ==200){
      print('Notification Deleted Succesfully');
    }
  }
}
