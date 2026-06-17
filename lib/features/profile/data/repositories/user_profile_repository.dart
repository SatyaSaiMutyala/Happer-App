import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/profile/models/user_profile_model.dart';

class UserProfileRepository {
  final ApiClient _client;
  UserProfileRepository(this._client);

  Future<UserProfileModel> fetchProfile() async {
    final response =
        await _client.get(ApiEndpoints.fetchProfile, requiresAuth: true);
    return UserProfileModel.fromJson(response);
  }

  Future<String> _compressImage(String filePath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/profile_upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );
    return result?.path ?? filePath;
  }

  Future<UserProfileModel> uploadProfileImage(String filePath) async {
    // Compress before upload to avoid 413
    final compressedPath = await _compressImage(filePath);

    // Step 1: upload file with file_type field, get back the S3 URL
    final uploadResponse = await _client.multipart(
      ApiEndpoints.fileUpload,
      method: 'POST',
      filePaths: {'file': compressedPath},
      fields: {'file_type': 'profile_image'},
      requiresAuth: true,
    );
    final data = uploadResponse['data'];
    final imageUrl = data is String
        ? data
        : (data is Map ? data['url'] as String? : null) ??
            uploadResponse['url'] as String? ??
            '';

    // Cleanup compressed temp file
    try { File(compressedPath).deleteSync(); } catch (e) { debugPrint('Temp file cleanup failed: $e'); }

    // Step 2: update profile image with the returned URL
    await _client.put(
      ApiEndpoints.updateProfileImage,
      body: {'profile_image': imageUrl},
      requiresAuth: true,
    );

    // Step 3: return refreshed profile
    return fetchProfile();
  }

  Future<void> completeEsign() {
    return _client.put(ApiEndpoints.completeEsign, requiresAuth: true);
  }

  Future<UserProfileModel> editProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String? picture,
    String? dob,
    int? gender,
    String? bio,
    String? instagramLink,
    String? mobileNumber,
    String? countryCode,
    String? streetAddress,
    String? postalCode,
    String? city,
  }) async {
    final body = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      if (picture != null && picture.isNotEmpty) 'profile_image': picture,
      if (dob != null && dob.isNotEmpty) 'dob': dob,
      if (gender != null) 'gender': gender,
      'bio': bio ?? '',
      'instagram_link': instagramLink ?? '',
      if (mobileNumber != null && mobileNumber.isNotEmpty) ...{
        'mobile_number': mobileNumber,
        if (countryCode != null && countryCode.isNotEmpty) 'country_code': countryCode,
      },
      'address': streetAddress ?? '',
      'postalcode': postalCode ?? '',
      'city': city ?? '',
    };
    await _client.put(ApiEndpoints.editProfile, body: body, requiresAuth: true);
    return fetchProfile();
  }
}
