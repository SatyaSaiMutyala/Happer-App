import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/network/api_endpoints.dart';
import 'package:happer_app/features/auth/data/models/auth_models.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<Map<String, dynamic>> signup(SignupRequest request) {
    return _client.post(ApiEndpoints.signup, body: request.toJson());
  }

  Future<Map<String, dynamic>> verifySignupOtp(String email, String otp) {
    return _client.post(
      ApiEndpoints.signupVerifyOtp,
      body: {'email': email, 'otp': otp},
    );
  }

  Future<Map<String, dynamic>> resendSignupOtp(String email) {
    return _client.post(
      ApiEndpoints.signupResendOtp,
      body: {'email': email},
    );
  }

  Future<UserModel> guestLogin() async {
    final response = await _client.post(
      ApiEndpoints.guestLogin,
      body: {'email': 'svssteja@gmail.com', 'password': 'classic@123'},
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> appleLogin({
    required String idToken,
    String? firstName,
    String? lastName,
  }) async {
    final body = <String, dynamic>{'id_token': idToken};
    if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName;
    if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;
    final response = await _client.post(ApiEndpoints.appleLogin, body: body);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> googleLogin({
    required String idToken,
    String? firstName,
    String? lastName,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{'id_token': idToken};
    if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName;
    if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;
    if (profileImage != null && profileImage.isNotEmpty) body['profile_image'] = profileImage;
    final response = await _client.post(ApiEndpoints.googleLogin, body: body);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> fetchProfile() async {
    final response = await _client.get(
      ApiEndpoints.fetchProfile,
      requiresAuth: true,
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> logout() {
    return _client.post(ApiEndpoints.logout, requiresAuth: true);
  }

  Future<void> registerDevice({
    required String platform,
    required String deviceModel,
    required String deviceId,
    required String deviceToken,
  }) {
    return _client.post(
      ApiEndpoints.registerDevice,
      body: {
        'platform': platform,
        'device_model': deviceModel,
        'device_id': deviceId,
        'device_token': deviceToken,
      },
      requiresAuth: true,
    );
  }

  Future<Map<String, dynamic>> forgotPassword(String email) {
    return _client.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email},
    );
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(
    String email,
    String otp,
  ) {
    return _client.post(
      ApiEndpoints.forgotPasswordVerifyOtp,
      body: {'email': email, 'otp': otp},
    );
  }

  Future<Map<String, dynamic>> resetPassword(String email, String password) {
    return _client.post(
      ApiEndpoints.resetPassword,
      body: {'email': email, 'password': password},
    );
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final response = await _client.post(
      ApiEndpoints.checkUsernameAvailability,
      body: {'username': username},
    );
    return response['is_username_available'] as bool? ?? true;
  }
}
