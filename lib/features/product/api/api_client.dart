// lib/services/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';
  static const String baseUrl = 'https://newapi.happer.fr/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to get user data');
    }
  }

  Future<bool> checkCanPostSelfie(String token) async {
   
    final response = await http.get(
      Uri.parse('$baseUrl/selfies/check'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

  

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        
        // If the API returns a specific can_post field, use it
        if (data is Map<String, dynamic> && data.containsKey('can_post')) {
          return data['can_post'] ?? false;
        }
        
        // If the API returns a message about uploading more selfies, return true
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          String message = data['message'].toString().toLowerCase();
          return message.contains('can upload') || message.contains('more selfies');
        }
        
        // If the response body directly contains the success message
        if (response.body.toLowerCase().contains('you can upload more selfies')) {
          return true;
        }
        
        // Otherwise, assume success means they can post
        return true;
      } catch (e) {
        // If we can't parse JSON, but got a 200 OK, check the raw response
     
        if (response.body.toLowerCase().contains('you can upload more selfies')) {
          return true;
        }
        // If status code is 200, assume they can post
        return true;
      }
    } else {
   
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories(String token) async {
   

    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Authorization': token},
    );

   

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);

      // Check if the API response has a data field or is directly an array
      final List<dynamic> categoriesData;
      if (decodedData is Map && decodedData.containsKey('data')) {
        // API returns { data: [...] }
        categoriesData = decodedData['data'];
      } else if (decodedData is List) {
        // API returns directly an array
        categoriesData = decodedData;
      } else {
    
        categoriesData = [];
      }

      return categoriesData
          .where((data) => data is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception(
        'Failed to get categories: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getUserItems(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/item_users/me'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      print('Decoded Data Type: ${decodedData.runtimeType}');
      print('Decoded Data: $decodedData');

      // Check if the API response has a data field or is directly an array
      final List<dynamic> itemsData;
      if (decodedData is Map && decodedData.containsKey('data')) {
        // API returns { data: [...] }
        itemsData = decodedData['data'];
        print('this is data itemsData $itemsData');
      } else if (decodedData is List) {
        // API returns directly an array
        itemsData = decodedData;
        print('API returns array directly: $itemsData');
      } else {
        print('Unexpected data format');
        itemsData = [];
      }

      final result = itemsData
          .where((data) => data is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .toList();

      print('Final parsed items count: ${result.length}');
      return result;
    } else {
      throw Exception('Failed to get user items: ${response.statusCode}');
    }
  }

  Future<bool> uploadSelfie(
  String token,
  Uint8List imageData,
  List<String> productIds, // These are just IDs like ["649197d0ccdd325a769a375e"]
) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageData);

    final File fileToUpload = tempFile; // Removed cropping logic
    final bytes = await fileToUpload.readAsBytes();

    final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';

    // Convert productIds to the required format
    final List<Map<String, dynamic>> itemsJson = productIds.map((id) => {
      "exact_match": true,
      "id": id,
    }).toList();

    final itemsJsonString = jsonEncode(itemsJson);

    final List<int> body = [];

    // File part
    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode('Content-Disposition: form-data; name="file"; filename="selfie.jpg"\r\n'));
    body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
    body.addAll(bytes);
    body.addAll(utf8.encode('\r\n'));

    // items_id part
    body.addAll(utf8.encode('--$boundary\r\n'));
    body.addAll(utf8.encode('Content-Disposition: form-data; name="items_id"\r\n\r\n'));
    body.addAll(utf8.encode(itemsJsonString));
    body.addAll(utf8.encode('\r\n'));

    // Close boundary
    body.addAll(utf8.encode('--$boundary--\r\n'));

    final request = http.Request('POST', Uri.parse('$baseUrl/selfies'));
    request.headers['Authorization'] = token;
    request.headers['Content-Type'] = 'multipart/form-data; boundary=$boundary';
    request.bodyBytes = body;

    final response = await http.Response.fromStream(await request.send());

    await _cleanupTempFiles(tempFile, null); // Removed croppedFile cleanup
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    return false;
  }
}
  // Helper method to clean up temporary files
  Future<void> _cleanupTempFiles(File tempFile, CroppedFile? croppedFile) async {
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    if (croppedFile != null && File(croppedFile.path).existsSync()) {
      await File(croppedFile.path).delete();
    }
  }

  
}
