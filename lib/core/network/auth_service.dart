// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
    static const String _baseUrl = 'https://newapi.happer.fr/api';
    // static const String _baseUrl = 'http://192.168.1.4:3001/api';

  // static const String _baseUrl =
  //     'https://happer-production.francecentral.cloudapp.azure.com/api'; // Replace with your API base URL

  Future<bool> loginUser(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/users/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final myId = data['id'];
        final token = data['token'];
        final refreshToken = data['refresh_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('myId', myId);
        await prefs.setString('token', token);
        await prefs.setString('refresh_token', refreshToken);

        // Fetch HapperVariables after successful login
        fetchHapperVariables(token).then((success) {
          if (success) {
            debugPrint('Successfully fetched HapperVariables after login');
          } else {
            debugPrint('Failed to fetch HapperVariables after login');
          }
        });

        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        debugPrint('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }

  Future<String?> sendEmailVerification(String email) async {
  try {
    final url = Uri.parse('$_baseUrl/users/email_verification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final verificationId = data['id'];
      debugPrint('Email verification sent successfully. ID: $verificationId');
      showAppSnackBar('Email verification sent successfully');
      return verificationId;
    } else {
      debugPrint('Failed to send email verification: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Error sending email verification: $e');
    return null;
  }
}


Future<bool> verifyEmailOtp(String verificationId, String otp) async {
  try {
    final url = Uri.parse('$_baseUrl/users/verify?id=$verificationId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Email verification successful: ${data.toString()}');
      return true;
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      debugPrint('Invalid OTP: ${response.body}');
      return false;
    } else {
      debugPrint('OTP verification failed: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Error verifying OTP: $e');
    return false;
  }
}

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return false;

      final url = Uri.parse('$_baseUrl/users/token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'];

        await prefs.setString('token', newToken);
        return true;
      } else {
        debugPrint('Token refresh failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during token refresh: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return null;

      final url = Uri.parse('$_baseUrl/users/profile/$userId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return getProfile(userId);
        } else {
          return null;
        }
      } else {
        debugPrint('Failed to fetch profile: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse('$_baseUrl/users/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Registration successful: ${response.body}');
        return true;
      } else {
        debugPrint('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      return false;
    }
  }

  Future<bool> sendPasswordResetCode(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/users/get_password_code');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        debugPrint('Password reset code sent successfully: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to send password reset code: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending password reset code: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String code, String email, String password) async {
    try {
      final url = Uri.parse('${_baseUrl}/users/reset_password');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        debugPrint('Password reset successful: ${response.body}');
        return true;
      } else {
        debugPrint('Password reset failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during password reset: $e');
      return false;
    }
  }

  // Use a static GoogleSignIn instance with explicit scopes
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      // Add more scopes if needed
    ],
    // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com', // Uncomment and set if needed
  );

  Future<GoogleSignInAccount?> googleSignInOnly() async {
    try {
      GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      googleUser ??= await _googleSignIn.signInSilently();
      googleUser ??= await _googleSignIn.signIn();
      return googleUser;
    } catch (e) {
      debugPrint('Error during Google Sign In: $e');
      return null;
    }
  }

  Future<UserCredential?> firebaseGoogleSignIn() async {
    try {
      // Configure GoogleSignIn with serverClientId for production
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        // This is the Web client ID from google-services.json
        // Required for backend authentication to work in production
        serverClientId: '287519573282-ereeovt3tp411982960kqdp4j4j3lutt.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('Google Sign In successful: ${googleUser.email}');
      debugPrint('Access Token: ${googleAuth.accessToken != null ? "Present" : "Missing"}');
      debugPrint('ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Firebase Google Sign In error: $e');
      return null;
    }
  }

  Future<bool> loginWithGoogleAccount(GoogleSignInAccount googleUser) async {
    final Map<String, String> payload = {
      'google_id': googleUser.id,
      'first_name': googleUser.displayName?.split(' ').first ?? '',
      'last_name': googleUser.displayName?.split(' ').last ?? '',
      'email': googleUser.email,
    };

    final url = Uri.parse('$_baseUrl/users/loginGoogle');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final myId = data['id'];
      final token = data['token'];
      final refreshToken = data['refresh_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('myId', myId);
      await prefs.setString('token', token);
      await prefs.setString('refresh_token', refreshToken);

      return true;
    } else {
      debugPrint('Google login failed: ${response.body}');
      return false;
    }
  }

  Future<bool> loginWithFirebaseGoogle(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return false;

    // Extract Google account ID from provider data
    String? googleId;
    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        googleId = provider.uid;
        break;
      }
    }
    googleId ??= user.uid; // fallback if not found

    final firstName = user.displayName?.split(' ').first ?? '';
    final lastName =
        (user.displayName?.split(' ').length ?? 0) > 1
            ? user.displayName!.split(' ').last
            : '';
    final email = user.email ?? '';

    final payload = {
      'google_id': googleId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
    debugPrint('Sending Google login payload: ' + payload.toString());

    final url = Uri.parse('$_baseUrl/users/loginGoogle');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('Backend Google login status: ${response.statusCode}');
    debugPrint('Backend Google login response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']?.toString();
      final refreshToken = data['refresh_token']?.toString();

      if (token == null || refreshToken == null) {
        debugPrint(
          'Token or refresh token is null: token=$token, refreshToken=$refreshToken',
        );
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('refresh_token', refreshToken);

      return true;
    } else {
      debugPrint('Backend Google login failed: ${response.body}');
      return false;
    }
  }

  /// Direct Apple Sign-In → Backend (native on iOS, web auth via own backend on Android)
  Future<bool> appleSignInAndBackendLogin() async {
    try {
      final AuthorizationCredentialAppleID credential;

      if (Platform.isAndroid) {
        // Android: Web auth flow via our own backend callback
        // Apple POSTs to our backend, which redirects back to the app via intent deep-link
        const String appleServiceId = 'fr.happer.app.service';
        const String appleRedirectUri = 'https://api.dev.happer.fr/api/callbacks/sign_in_with_apple';

        credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: appleServiceId,
            redirectUri: Uri.parse(appleRedirectUri),
          ),
        );
      } else {
        // iOS: Native Sign in with Apple
        credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
      }

      // On Android web flow, the plugin hardcodes userIdentifier=null.
      // Extract the Apple user ID (sub) from the id_token JWT instead.
      String? appleId = credential.userIdentifier;
      if (appleId == null && credential.identityToken != null) {
        try {
          final parts = credential.identityToken!.split('.');
          if (parts.length >= 2) {
            // JWT payload is base64url encoded — pad to multiple of 4
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
            appleId = decoded['sub'] as String?;
            debugPrint('Extracted Apple sub from id_token: $appleId');
          }
        } catch (e) {
          debugPrint('Failed to decode id_token: $e');
        }
      }

      final email = credential.email;
      final firstName = credential.givenName;
      final lastName = credential.familyName;

      debugPrint('Apple credential received:');
      debugPrint('  userIdentifier: $appleId');
      debugPrint('  email: $email');
      debugPrint('  givenName: $firstName');
      debugPrint('  familyName: $lastName');

      if (appleId == null) {
        debugPrint('Apple ID is null — no userIdentifier or id_token sub found');
        throw Exception('Identifiant Apple manquant');
      }

      // Apple only provides name/email on FIRST sign-in, store them locally
      final prefs = await SharedPreferences.getInstance();
      if (firstName != null) {
        await prefs.setString('apple_given_name', firstName);
      }
      if (lastName != null) {
        await prefs.setString('apple_family_name', lastName);
      }

      // Use stored name if Apple didn't provide it (subsequent sign-ins)
      final finalFirstName = firstName ?? prefs.getString('apple_given_name') ?? '';
      final finalLastName = lastName ?? prefs.getString('apple_family_name') ?? '';

      final payload = {
        'apple_id': appleId,
        'first_name': finalFirstName,
        'last_name': finalLastName,
        'email': email ?? '',
      };
      debugPrint('Sending Apple login payload: $payload');

      final url = Uri.parse('$_baseUrl/users/loginApple');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('Backend Apple login status: ${response.statusCode}');
      debugPrint('Backend Apple login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final myId = data['id']?.toString();
        final token = data['token']?.toString();
        final refreshToken = data['refresh_token']?.toString();

        if (token == null || refreshToken == null) {
          debugPrint('Token or refresh token is null');
          throw Exception('Tokens de connexion manquants');
        }

        await prefs.setString('token', token);
        await prefs.setString('refresh_token', refreshToken);
        if (myId != null) {
          await prefs.setString('myId', myId);
        }

        // Fetch HapperVariables after successful login
        fetchHapperVariables(token).then((success) {
          debugPrint(success
              ? 'Successfully fetched HapperVariables after Apple login'
              : 'Failed to fetch HapperVariables after Apple login');
        });

        return true;
      } else {
        debugPrint('Backend Apple login failed: ${response.body}');
        throw Exception('Échec de la connexion Apple (${response.statusCode})');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('CANCELLED');
      }
      debugPrint('Apple Sign In authorization error: ${e.code} - ${e.message}');
      throw Exception('Erreur Apple Sign-In: ${e.message}');
    } catch (e) {
      if (e.toString().contains('CANCELLED')) {
        rethrow;
      }
      debugPrint('Apple Sign In error: $e');
      rethrow;
    }
  }

  // Old commented-out version removed (replaced by appleSignInAndBackendLogin above)
  // Future<bool> appleSignInAndBackendLogin() async {
  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );

  //     final appleId = credential.userIdentifier;
  //     final email = credential.email;
  //     final firstName = credential.givenName;
  //     final lastName = credential.familyName;

  //     // If user is signing in again, Apple may not return email/name, so fetch from elsewhere if needed
  //     if (appleId == null) {
  //       debugPrint('Apple ID is null');
  //       return false;
  //     }

  //     final payload = {
  //       'apple_id': appleId,
  //       'first_name': firstName ?? '',
  //       'last_name': lastName ?? '',
  //       'email': email ?? '',
  //     };
  //     debugPrint('Sending Apple login payload: ' + payload.toString());

  //     final url = Uri.parse('$_baseUrl/users/loginApple');
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(payload),
  //     );

  //     debugPrint('Backend Apple login status: [33m${response.statusCode}[0m');
  //     debugPrint('Backend Apple login response: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final token = data['token']?.toString();
  //       final refreshToken = data['refresh_token']?.toString();

  //       if (token == null || refreshToken == null) {
  //         debugPrint(
  //           'Token or refresh token is null: token=$token, refreshToken=$refreshToken',
  //         );
  //         return false;
  //       }

  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', token);
  //       await prefs.setString('refresh_token', refreshToken);

  //       return true;
  //     } else {
  //       debugPrint('Backend Apple login failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Apple Sign In error: $e');
  //     return false;
  //   }
  // }

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> firebaseAppleSignIn() async {
    try {
      debugPrint('Starting Apple Sign-In...');
      debugPrint('Platform: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Other"}');

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      debugPrint('🔐 rawNonce: $rawNonce');
      debugPrint('🔐 hashedNonce: $nonce');
      debugPrint('Generated nonce for Apple Sign-In');

      // For Android, we need to use web authentication
      // For iOS, native Sign in with Apple is used
      final AuthorizationCredentialAppleID appleCredential;

      if (Platform.isAndroid) {
        debugPrint('🤖 Android detected - using web authentication flow');

        // Configuration for Apple Sign-In on Android
        const String appleServiceId = 'fr.happer.app.service';
        const String appleRedirectUri = 'https://happer-b272b.firebaseapp.com/__/auth/handler';

        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('🍎 APPLE SIGN-IN - ANDROID WEB AUTH CONFIGURATION');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📋 WHAT IS BEING SENT TO APPLE:');
        debugPrint('   client_id (Service ID): $appleServiceId');
        debugPrint('   redirect_uri: $appleRedirectUri');
        debugPrint('   nonce (hashed): $nonce');
        debugPrint('   scopes: email, fullName');
        debugPrint('───────────────────────────────────────────────────────────');
        debugPrint('⚠️  MAKE SURE IN APPLE DEVELOPER PORTAL:');
        debugPrint('   1. Service ID "$appleServiceId" exists');
        debugPrint('   2. Sign in with Apple is ENABLED for this Service ID');
        debugPrint('   3. Website URLs configured:');
        debugPrint('      - Domain: newapi.happer.fr');
        debugPrint('      - Return URL: $appleRedirectUri');
        debugPrint('═══════════════════════════════════════════════════════════');

        // Android requires web authentication options
        // You need to set up a redirect URL on your backend
        appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: appleServiceId,
            redirectUri: Uri.parse(appleRedirectUri),
          ),
        );
      } else {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('🍎 iOS APPLE SIGN-IN - NATIVE FLOW');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('📋 iOS NATIVE SIGN-IN CONFIGURATION:');
        debugPrint('   - Uses native iOS Sign in with Apple');
        debugPrint('   - No web redirect needed');
        debugPrint('   - Credentials come directly from iOS system');
        debugPrint('───────────────────────────────────────────────────────────');
        debugPrint('⚠️  MAKE SURE IN APPLE DEVELOPER PORTAL:');
        debugPrint('   1. App ID has "Sign in with Apple" ENABLED');
        debugPrint('   2. In Xcode: Runner → Signing & Capabilities → Sign in with Apple');
        debugPrint('───────────────────────────────────────────────────────────');
        debugPrint('⚠️  MAKE SURE IN FIREBASE CONSOLE:');
        debugPrint('   1. Authentication → Sign-in method → Apple → ENABLED');
        debugPrint('   2. Apple Team ID is configured');
        debugPrint('═══════════════════════════════════════════════════════════');

        // iOS uses native Sign in with Apple
        appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );
      }


      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🍎 APPLE SIGN-IN - CREDENTIAL RECEIVED FROM APPLE');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ Apple login success');
      debugPrint('🧾 Identity Token Present: ${appleCredential.identityToken != null}');
      debugPrint('🔑 Authorization Code Present: ${appleCredential.authorizationCode != null}');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('👤 USER INFO FROM APPLE:');
      debugPrint('   User Identifier: ${appleCredential.userIdentifier ?? "Not provided"}');
      debugPrint('   Email: ${appleCredential.email ?? "Not provided (only on first sign-in)"}');
      debugPrint('   Given Name: ${appleCredential.givenName ?? "Not provided (only on first sign-in)"}');
      debugPrint('   Family Name: ${appleCredential.familyName ?? "Not provided (only on first sign-in)"}');
      debugPrint('   State: ${appleCredential.state ?? "None"}');
      debugPrint('═══════════════════════════════════════════════════════════');

      if (appleCredential.identityToken == null) {
        debugPrint('ERROR: Identity token is null');
        throw Exception('Token d\'identité Apple manquant');
      }

      // Create OAuth credential for Firebase with nonce
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
      );

      debugPrint('Signing in to Firebase with nonce...');
      debugPrint('idToken length: ${appleCredential.identityToken!.length}');
      debugPrint('rawNonce: $rawNonce');

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      debugPrint('Firebase sign-in successful!');
      debugPrint('Firebase User ID: ${userCredential.user?.uid}');
      debugPrint('Firebase User Email: ${userCredential.user?.email}');

      // Store name if provided (only available on first sign-in)
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final prefs = await SharedPreferences.getInstance();
        if (appleCredential.givenName != null) {
          await prefs.setString('apple_given_name', appleCredential.givenName!);
        }
        if (appleCredential.familyName != null) {
          await prefs.setString('apple_family_name', appleCredential.familyName!);
        }
        debugPrint('Stored Apple user name in SharedPreferences');
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle specific Apple Sign-In errors
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('Apple Sign-In cancelled by user');
        throw Exception('CANCELLED');
      } else if (e.code == AuthorizationErrorCode.failed) {
        debugPrint('Apple Sign-In failed: ${e.message}');
        throw Exception('La connexion Apple a échoué. Veuillez réessayer.');
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        debugPrint('Apple Sign-In not handled: ${e.message}');
        throw Exception('Erreur de configuration Apple Sign-In');
      } else if (e.code == AuthorizationErrorCode.unknown) {
        debugPrint('Apple Sign-In unknown error: ${e.message}');
        throw Exception('Erreur inconnue lors de la connexion Apple');
      } else {
        debugPrint('Apple Sign-In authorization error: ${e.code} - ${e.message}');
        throw Exception('Erreur d\'autorisation Apple: ${e.message}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('FIREBASE AUTH ERROR DETAILS');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('Error Code: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Email: ${e.email}');
      debugPrint('Credential: ${e.credential}');
      debugPrint('Plugin: ${e.plugin}');
      debugPrint('Stack Trace: ${e.stackTrace}');
      debugPrint('═══════════════════════════════════════════════════════════');
      if (e.code == 'invalid-credential') {
        debugPrint('FIX: Go to Firebase Console → Authentication → Sign-in method → Apple → ENABLE it and add your Apple Team ID');
        throw Exception('Identifiants Apple invalides. Vérifiez la configuration Firebase Apple Sign-In.');
      } else if (e.code == 'user-disabled') {
        throw Exception('Ce compte a été désactivé');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('La connexion Apple n\'est pas activée');
      } else {
        throw Exception('Erreur Firebase: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('CANCELLED')) {
        rethrow;
      }
      debugPrint('Firebase Apple Sign In error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<void> signInWithApple() async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // credential contains:
    // - credential.userIdentifier (stable id)
    // - credential.identityToken (JWT)
    // - credential.authorizationCode
    // - credential.email, credential.givenName, credential.familyName (only on FIRST sign-in)
    final identityToken = credential.identityToken;
    final authorizationCode = credential.authorizationCode;
    final userIdentifier = credential.userIdentifier;

    // 1) Send identityToken/authorizationCode/userIdentifier to your backend
    // 2) Backend verifies token with Apple and creates/returns your app session
    // IMPORTANT: store name/email locally on first sign-in — Apple only provides them once.
  } catch (e) {
    // handle errors / user cancelation
    rethrow;
  }
}

  Future<bool> loginWithFirebaseEmailPassword(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return false;

      // Optionally, get ID token if backend needs it
      // final idToken = await user.getIdToken();

      // Call your backend login endpoint if needed, or just return true
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase email/password login error: [31m${e.code}[0m - ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('Firebase email/password login error: $e');
      return false;
    }
  }

  Future<bool> loginWithFirebaseApple(UserCredential userCredential) async {
    try {
      final user = userCredential.user;
      if (user == null) {
        debugPrint('ERROR: Firebase user is null');
        throw Exception('Utilisateur Firebase introuvable');
      }

      debugPrint('Processing Apple login for Firebase user: ${user.uid}');

      // Use Firebase UID as apple_id
      final appleId = user.uid;
      final email = user.email ?? '';

      // Try to get name from different sources
      String firstName = '';
      String lastName = '';

      // First, try from SharedPreferences (stored during first sign-in)
      final prefs = await SharedPreferences.getInstance();
      firstName = prefs.getString('apple_given_name') ?? '';
      lastName = prefs.getString('apple_family_name') ?? '';

      debugPrint('Name from SharedPreferences: $firstName $lastName');

      // If not in SharedPreferences, try from displayName
      if (firstName.isEmpty && lastName.isEmpty) {
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          final parts = user.displayName!.trim().split(' ');
          firstName = parts.first;
          if (parts.length > 1) {
            lastName = parts.sublist(1).join(' ');
          }
          debugPrint('Name from displayName: $firstName $lastName');
        }
      }

      // If still empty, check provider data
      if (firstName.isEmpty && lastName.isEmpty) {
        for (final provider in user.providerData) {
          if (provider.displayName != null && provider.displayName!.isNotEmpty) {
            final parts = provider.displayName!.split(' ');
            firstName = parts.first;
            if (parts.length > 1) {
              lastName = parts.sublist(1).join(' ');
            }
            debugPrint('Name from provider data: $firstName $lastName');
            break;
          }
        }
      }

      final payload = {
        'apple_id': appleId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🍎 APPLE LOGIN - SENDING TO BACKEND');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📍 Endpoint: $_baseUrl/users/loginApple');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('📦 PAYLOAD:');
      debugPrint('   apple_id: $appleId');
      debugPrint('   email: $email');
      debugPrint('   first_name: $firstName');
      debugPrint('   last_name: $lastName');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('📋 BACKEND CONFIGURATION NEEDED:');
      debugPrint('   Service ID: fr.happer.app.service');
      debugPrint('   Apple Team ID: (from Apple Developer account)');
      debugPrint('   Key ID: (from .p8 key created in Apple Developer)');
      debugPrint('   Private Key: (contents of .p8 file)');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('🔑 Firebase User Info:');
      debugPrint('   Firebase UID: ${user.uid}');
      debugPrint('   Firebase Email: ${user.email}');
      debugPrint('   Firebase Display Name: ${user.displayName}');
      debugPrint('   Provider Data: ${user.providerData.map((p) => '${p.providerId}: ${p.uid}').join(', ')}');
      debugPrint('═══════════════════════════════════════════════════════════');

      final url = Uri.parse('$_baseUrl/users/loginApple');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🍎 APPLE LOGIN - BACKEND RESPONSE');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');
      debugPrint('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final myId = data['id']?.toString();
        final token = data['token']?.toString();
        final refreshToken = data['refresh_token']?.toString();

        if (token == null || refreshToken == null) {
          debugPrint(
            'ERROR: Token or refresh token is null: token=$token, refreshToken=$refreshToken',
          );
          throw Exception('Tokens de connexion manquants dans la réponse du serveur');
        }

        await prefs.setString('token', token);
        await prefs.setString('refresh_token', refreshToken);
        if (myId != null) {
          await prefs.setString('myId', myId);
        }

        debugPrint('Apple login successful! Tokens saved.');

        // Fetch HapperVariables after successful login
        fetchHapperVariables(token).then((success) {
          if (success) {
            debugPrint('Successfully fetched HapperVariables after Apple login');
          } else {
            debugPrint('Failed to fetch HapperVariables after Apple login');
          }
        });

        return true;
      } else if (response.statusCode == 401) {
        debugPrint('Backend Apple login unauthorized: ${response.body}');
        throw Exception('Identifiants Apple non autorisés');
      } else if (response.statusCode == 400) {
        debugPrint('Backend Apple login bad request: ${response.body}');
        throw Exception('Données de connexion invalides');
      } else if (response.statusCode >= 500) {
        debugPrint('Backend Apple login server error: ${response.statusCode} - ${response.body}');
        throw Exception('Erreur du serveur. Veuillez réessayer plus tard.');
      } else {
        debugPrint('Backend Apple login failed: ${response.statusCode} - ${response.body}');
        throw Exception('Échec de la connexion au serveur (${response.statusCode})');
      }
    } catch (e, stackTrace) {
      debugPrint('Exception in loginWithFirebaseApple: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetches Happer configuration variables from the API
  /// Returns true if successful, false otherwise
  Future<bool> fetchHapperVariables(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/happer_var');
      final response = await http.get(
        url,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        // Store raw response in SharedPreferences
        await prefs.setString('happer_variables', response.body);

        // Simply find and store the time_to_rest value directly
        for (var item in responseData) {
          if (item is Map<String, dynamic>) {
            final name = item['name'];
            final value = item['var'];

            // Save time_to_rest directly with its key
            if (name == 'time_to_rest') {
              await prefs.setString('time_to_rest', value.toString());
              debugPrint('Saved time_to_rest = $value in SharedPreferences');
              break; // Found what we needed, no need to continue
            }
          }
        }

        return true;
      } else {
        debugPrint(
          'Failed to fetch HapperVariables: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching HapperVariables: $e');
      return false;
    }
  }

  // No static method needed - other parts of the app can directly access
  // SharedPreferences.getInstance().then((prefs) => prefs.getString('time_to_rest') ?? '30');

Future<bool> verifyEmail(String email) async {
  try {
    final url = Uri.parse('$_baseUrl/users/email_verification?email=$email');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Email verification check successful: ${response.body}');
      return true;
    } else {
      debugPrint('Email verification failed: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Error during email verification: $e');
    return false;
  }
}

}
