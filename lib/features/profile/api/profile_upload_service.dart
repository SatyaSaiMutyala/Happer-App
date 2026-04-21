import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUploadService {
    static const String baseUrl = 'https://newapi.happer.fr/api';

  //static const String baseUrl = 'https://happer-production.francecentral.cloudapp.azure.com/api';

  /// Uploads a profile picture to the API
  Future<Map<String, dynamic>?> uploadProfilePicture(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Token not found or invalid');
        return {
          'error': 'You need to be logged in to upload a profile picture.',
        };
      }

      // Check file size
      final fileSizeInMB = await imageFile.length() / (1024 * 1024);
      if (fileSizeInMB > 10) {
        return {
          'error':
              'Image is too large (${fileSizeInMB.toStringAsFixed(2)} MB). Maximum size is 10 MB.',
        };
      }

      // Compress the image before uploading
      File compressedFile = await _compressImage(imageFile);

      // Check if the compressed file is still too large (> 5MB), compress again with more aggressive settings
      final compressedSizeInMB = await compressedFile.length() / (1024 * 1024);
      if (compressedSizeInMB > 5) {
        debugPrint(
          'First compression still too large: ${compressedSizeInMB.toStringAsFixed(2)} MB, compressing again...',
        );

        // Create a temporary file for the second compression
        final directory = await getTemporaryDirectory();
        final targetPath = '${directory.path}/compressed_profile_pic_extra.jpg';

        // Extra compression
        final extraCompressedFile =
            await FlutterImageCompress.compressAndGetFile(
              compressedFile.absolute.path,
              targetPath,
              quality: 30,
              minWidth: 300,
              minHeight: 300,
              format: CompressFormat.jpeg,
            );

        if (extraCompressedFile != null) {
          compressedFile = File(extraCompressedFile.path);
          final newSizeInMB = await compressedFile.length() / (1024 * 1024);
          debugPrint(
            'After second compression: ${newSizeInMB.toStringAsFixed(2)} MB',
          );
        }
      }

      final url = Uri.parse('$baseUrl/users/upload');

      // APPROACH: Using manual multipart form construction similar to uploadSelfie
      // Create a boundary for multipart form
      final boundary =
          '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';

      // Read the compressed file as bytes
      final bytes = await compressedFile.readAsBytes();

      // Create the multipart body manually
      final List<int> body = [];

      // Add file part
      body.addAll(utf8.encode('--$boundary\r\n'));
      body.addAll(
        utf8.encode(
          'Content-Disposition: form-data; name="file"; filename="${compressedFile.path.split('/').last}"\r\n',
        ),
      );
      body.addAll(utf8.encode('Content-Type: image/jpeg\r\n\r\n'));
      body.addAll(bytes);
      body.addAll(utf8.encode('\r\n'));

      // Close the multipart form
      body.addAll(utf8.encode('--$boundary--\r\n'));

      // Send the request with custom headers
      final request = http.Request('POST', url);
      request.headers['Authorization'] = token;
      request.headers['Content-Type'] =
          'multipart/form-data; boundary=$boundary';
      request.bodyBytes = body;

      debugPrint('Upload Request URL: ${request.url}');
      debugPrint('Upload Request headers: ${request.headers}');
      debugPrint('Upload Request body size: ${request.bodyBytes.length} bytes');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Profile picture uploaded successfully');

        // Fetch updated user profile to ensure all data is current
        await _refreshUserData();

        return Map<String, dynamic>.from(json.decode(response.body));
      } else if (response.statusCode == 413) {
        final fileSizeInMB = await compressedFile.length() / (1024 * 1024);
        debugPrint(
          'File still too large after compression: ${fileSizeInMB.toStringAsFixed(2)} MB',
        );
        return {
          'error':
              'The image is too large for the server to process (${fileSizeInMB.toStringAsFixed(2)} MB). '
              'Please try a smaller image or with lower resolution.',
        };
      } else if (response.statusCode == 500) {
        // Special handling for server errors
        debugPrint('Server error (500) while uploading profile picture');
        // Since manual multipart construction works for selfie uploads, this should now be fixed
        return {
          'error':
              'The server encountered an error processing the image. Please try a different image or try again later.',
        };
      } else {
        debugPrint(
          'Failed to upload profile picture: ${response.statusCode} - ${response.body}',
        );
        return {
          'error':
              'Failed to upload profile picture (Status code: ${response.statusCode}). Please try again later.',
        };
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return {'error': 'Error during upload: ${e.toString()}'};
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

  /// Compresses the image file to reduce its size
  Future<File> _compressImage(File file) async {
    // Get the file extension
    final path = file.path;
    final lastIndex = path.lastIndexOf('.');
    final extension = lastIndex != -1 ? path.substring(lastIndex) : '.jpg';

    // Create a temporary file to store the compressed image
    final directory = await getTemporaryDirectory();
    final targetPath = '${directory.path}/compressed_profile_pic$extension';

    // Get original file size in KB
    final originalSize = await file.length() / 1024;
    debugPrint('Original image size: ${originalSize.toStringAsFixed(2)} KB');

    // Compression quality based on original size
    int quality = 90;
    int maxWidth = 800;
    int maxHeight = 800;

    // More aggressive compression for larger files
    if (originalSize > 2000) {
      // Over 2MB
      quality = 50;
      maxWidth = 500;
      maxHeight = 500;
    } else if (originalSize > 1000) {
      // Over 1MB
      quality = 60;
      maxWidth = 600;
      maxHeight = 600;
    } else if (originalSize > 500) {
      // Over 500KB
      quality = 70;
      maxWidth = 700;
      maxHeight = 700;
    }

    // Compress the image
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
      rotate: 0,
      format:
          extension.toLowerCase().endsWith('.png')
              ? CompressFormat.png
              : CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      // If compression fails, return the original file
      debugPrint('Image compression failed, using original file');
      return file;
    }

    final compressedSize = await File(compressedFile.path).length() / 1024;
    debugPrint(
      'Compressed image size: ${compressedSize.toStringAsFixed(2)} KB (${(compressedSize / originalSize * 100).toStringAsFixed(2)}% of original)',
    );

    return File(compressedFile.path);
  }

  /// Refreshes user data from the server after successful profile upload
  Future<void> _refreshUserData() async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('Cannot refresh user data: Token not found or invalid');
        return;
      }

      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.get(url, headers: {'Authorization': token});

      if (response.statusCode == 200) {
        debugPrint(
          'User data refreshed successfully after profile picture update',
        );
      } else {
        debugPrint('Failed to refresh user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }
}
