import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/network/api_exceptions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/features/auth/data/models/auth_models.dart';
import 'package:happer_app/features/auth/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  final isLoading = false.obs;
  final isCheckingUsername = false.obs;

  void _showError(String message) => showAppSnackBar(message, isSuccess: false);

  void _showSuccess(String message) =>
      showAppSnackBar(message, isSuccess: true);

  // Returns true if available, false if taken. Throws on network error (caller handles silently).
  Future<bool> checkUsernameAvailability(String username) async {
    isCheckingUsername.value = true;
    try {
      return await _repo.checkUsernameAvailability(username);
    } finally {
      isCheckingUsername.value = false;
    }
  }

  Future<void> signup({
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    String? referredByCode,
  }) async {
    if (email.isEmpty ||
        firstName.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _repo.signup(
        SignupRequest(
          email: email.trim().toLowerCase(),
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          username: username.trim(),
          password: password,
          referredByCode: referredByCode?.trim(),
        ),
      );
      final message =
          response['message'] as String? ??
          'A verification code has been sent to your email.';
      _showSuccess(message);
      Get.toNamed(
        AppRoutes.signupOtp,
        arguments: {'email': email.trim().toLowerCase(), 'password': password},
      );
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySignupOtp(
    String email,
    String otp, {
    String? password,
  }) async {
    if (otp.length < 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }
    isLoading.value = true;
    try {
      await _repo.verifySignupOtp(email, otp.trim());

      // Auto-login after verification so user goes straight to dashboard
      if (password != null && password.isNotEmpty) {
        try {
          final user = await _repo.login(email, password);
          await StorageService.saveToken(user.accessToken!);
          if (user.refreshToken != null) {
            await StorageService.saveRefreshToken(user.refreshToken!);
          }
          await StorageService.saveUserId(user.id);
          await StorageService.setGuestLogin(false);
          _showSuccess('Compte vérifié avec succès !');
          Get.offAllNamed(AppRoutes.dashboard);
          return;
        } catch (_) {
          // Auto-login failed — fall back to login screen
        }
      }

      _showSuccess('Compte vérifié. Veuillez vous connecter.');
      Get.offAllNamed(AppRoutes.login);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('OTP verification failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendSignupOtp(String email) async {
    isLoading.value = true;
    try {
      final response = await _repo.resendSignupOtp(email);
      final message =
          response['message'] as String? ??
          'A new OTP has been sent to your email.';
      _showSuccess(message);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Failed to resend OTP. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _appleLog(String message) {
    dev.log(message, name: 'AppleLogin');
    debugPrint('[AppleLogin] $message');
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    // Tracks which domain we're in so the generic catch blocks can attribute
    // the failure: APPLE (Apple sign-in) / FIREBASE (token exchange) / BACKEND (our API) / STORAGE.
    var stage = 'INIT';
    _appleLog(
      '━━━━━━━━ APPLE LOGIN START (platform: ${Platform.isIOS ? "iOS" : "Android"}) ━━━━━━━━',
    );
    try {
      // Resolved below per-platform; both paths converge on a Firebase UserCredential.
      final UserCredential firebaseResult;
      String? firstName;
      String? lastName;

      if (Platform.isAndroid) {
        // ─────────────── ANDROID: Firebase-managed Apple OAuth ───────────────
        // IMPORTANT: We must NOT use sign_in_with_apple + signInWithCredential here.
        // That flow returns an identityToken whose `aud` is the Apple *Services ID*
        // (fr.happer.app.service). FirebaseAuth.signInWithCredential validates the
        // Apple token's `aud` against the project's registered iOS *bundle ID*
        // (fr.happer.app), NOT the Services ID — so it always fails with
        // "audience … does not match the expected audience".
        // signInWithProvider lets Firebase run the whole OAuth handshake itself
        // (using the Services ID + key configured in the Firebase console), so the
        // audience is correct. Requires the Firebase handler URL
        // (https://happer-b272b.firebaseapp.com/__/auth/handler) to be registered
        // in the Apple Services ID "Return URLs".
        stage = 'FIREBASE';
        _appleLog(
          '[1-2/3 FIREBASE] Android — signInWithProvider(AppleAuthProvider)…',
        );
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        firebaseResult = await FirebaseAuth.instance.signInWithProvider(
          appleProvider,
        );

        // Apple returns the name only on the very first consent; Firebase exposes it
        // via displayName. Split & cache for later logins.
        final display = firebaseResult.user?.displayName?.trim();
        if (display != null && display.isNotEmpty) {
          final parts = display.split(RegExp(r'\s+'));
          firstName = parts.first;
          lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        }
      } else {
        // ─────────────── iOS: Firebase-managed Apple OAuth ───────────────
        // signInWithCredential with the native Apple token fails because Firebase
        // calls Apple's server using the Services ID as client_id, but the native
        // token's aud = bundle ID — Apple rejects the mismatch ("Invalid OAuth
        // response"). signInWithProvider lets Firebase own the full handshake using
        // the Services ID consistently, the same way Android does.
        // Requires the Firebase handler URL
        // (https://happer-b272b.firebaseapp.com/__/auth/handler) to be registered
        // in the Apple Services ID "Return URLs".
        stage = 'FIREBASE';
        _appleLog('[1-2/3 FIREBASE] iOS — signInWithProvider(AppleAuthProvider)…');
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        firebaseResult = await FirebaseAuth.instance.signInWithProvider(
          appleProvider,
        );

        final display = firebaseResult.user?.displayName?.trim();
        if (display != null && display.isNotEmpty) {
          final parts = display.split(RegExp(r'\s+'));
          firstName = parts.first;
          lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
        }
      }

      // Apple only provides name on the very first sign-in — cache & restore it so
      // later logins (which omit the name) still send it to our backend.
      final prefs = await SharedPreferences.getInstance();
      if (firstName != null)
        await prefs.setString('apple_first_name', firstName);
      if (lastName != null) await prefs.setString('apple_last_name', lastName);
      firstName ??= prefs.getString('apple_first_name');
      lastName ??= prefs.getString('apple_last_name');

      final firebaseIdToken = await firebaseResult.user?.getIdToken();
      _appleLog(
        '[2/3 FIREBASE] ✔ Sign-in complete — uid=${firebaseResult.user?.uid} '
        'email=${firebaseResult.user?.email} '
        'name=$firstName $lastName '
        'idToken=${firebaseIdToken != null ? "present" : "NULL"}',
      );

      if (firebaseIdToken == null) {
        _appleLog('[2/3 FIREBASE] ✖ Firebase ID token is NULL');
        _showError(
          'Apple Sign In failed: could not get Firebase token. Please try again.',
        );
        return;
      }

      // ─────────────── STAGE 3/3: BACKEND — appleLogin API + store token ───────────────
      stage = 'BACKEND';
      _appleLog('[3/3 BACKEND] Calling appleLogin API with Firebase ID token…');
      final user = await _repo.appleLogin(
        idToken: firebaseIdToken,
        firstName: firstName,
        lastName: lastName,
      );
      _appleLog(
        '[3/3 BACKEND] ✔ API responded — userId=${user.id} '
        'accessToken=${(user.accessToken?.isNotEmpty ?? false) ? "present" : "NULL/empty"} '
        'refreshToken=${(user.refreshToken?.isNotEmpty ?? false) ? "present" : "NULL/empty"}',
      );

      final accessToken = user.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        _appleLog('[3/3 BACKEND] ✖ Backend returned null/empty access token');
        _showError(
          'Apple Sign In failed: no access token from server. Please try again.',
        );
        return;
      }

      stage = 'STORAGE';
      _appleLog('[STORAGE] Persisting tokens & session…');
      await StorageService.saveToken(accessToken);
      await StorageService.saveRefreshToken(user.refreshToken ?? '');
      await StorageService.saveUserId(user.id);
      await StorageService.setLoginMethod('apple');
      await StorageService.setGuestLogin(false);

      _appleLog('━━━━━━━━ ✔ APPLE LOGIN SUCCESS (userId=${user.id}) ━━━━━━━━');
      _postLoginSetup();
      Get.offAllNamed(AppRoutes.dashboard);
    } on AppException catch (e) {
      // AppException is thrown by our repository/API layer → BACKEND domain.
      _appleLog(
        '✖ [stage=$stage] BACKEND/API error (AppException): ${e.message}',
      );
      _showError(e.message);
    } on FirebaseAuthException catch (e) {
      // User dismissed the Firebase-managed OAuth tab (Android) — not an error.
      if (e.code == 'canceled' ||
          e.code == 'web-context-canceled' ||
          e.code == 'web-context-cancelled' ||
          e.code == 'user-cancelled') {
        _appleLog('   → User canceled the Apple sign-in flow (not an error)');
        return;
      }
      // FirebaseAuth rejected the Apple credential → FIREBASE / Apple-config domain.
      _appleLog('✖ [stage=FIREBASE] FirebaseAuthException: code=${e.code}');
      _appleLog('   message: ${e.message}');
      _appleLog(
        '   → FIREBASE/APPLE-CONFIG issue (not the backend API). Common causes:',
      );
      _appleLog(
        '      • invalid-credential + "audience…does not match" → Apple `aud` ≠ Firebase expected audience (use signInWithProvider on Android, not signInWithCredential)',
      );
      _appleLog(
        '      • operation-not-allowed → Apple provider not enabled in Firebase Console',
      );
      _appleLog(
        '      • web flow error → Firebase handler URL not in Apple Services ID Return URLs',
      );
      if (e.code == 'invalid-credential' &&
          (e.message ?? '').contains('OAuth response from apple')) {
        _showError(
          'Apple Sign In requires a real iPhone — not supported on iOS Simulator.',
        );
      } else {
        _showError('Authentication error: ${e.message ?? "Please try again."}');
      }
    } catch (e, st) {
      _appleLog('✖ [stage=$stage] Unexpected error: $e');
      dev.log('stack trace', name: 'AppleLogin', error: e, stackTrace: st);
      _showError('Apple Sign In failed. Please try again.');
    } finally {
      isLoading.value = false;
      _appleLog('━━━━━━━━ APPLE LOGIN END ━━━━━━━━');
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    dev.log('▶ Google login started', name: 'GoogleLogin');
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId:
            '287519573282-ereeovt3tp411982960kqdp4j4j3lutt.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        dev.log('User cancelled Google sign-in', name: 'GoogleLogin');
        return;
      }
      dev.log(
        '✔ Google account selected — ${account.email}',
        name: 'GoogleLogin',
      );

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final firebaseResult = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await firebaseResult.user?.getIdToken();
      dev.log(
        '✔ Firebase sign-in complete — uid=${firebaseResult.user?.uid} idToken=${firebaseIdToken != null ? "present" : "NULL"}',
        name: 'GoogleLogin',
      );

      if (firebaseIdToken == null) {
        dev.log('✖ Firebase ID token is null', name: 'GoogleLogin');
        _showError('Google Sign In failed. Please try again.');
        return;
      }

      final nameParts = (account.displayName ?? '').split(' ');
      final user = await _repo.googleLogin(
        idToken: firebaseIdToken,
        firstName: nameParts.isNotEmpty ? nameParts.first : null,
        lastName: nameParts.length > 1 ? nameParts.last : null,
        profileImage: account.photoUrl,
      );

      final accessToken = user.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        dev.log(
          '✖ Backend returned null/empty access token',
          name: 'GoogleLogin',
        );
        _showError('Google Sign In failed: no access token from server.');
        return;
      }

      dev.log(
        '✔ Backend login success — userId=${user.id}',
        name: 'GoogleLogin',
      );
      await StorageService.saveToken(accessToken);
      await StorageService.saveRefreshToken(user.refreshToken ?? '');
      await StorageService.saveUserId(user.id);
      await StorageService.setLoginMethod('google');
      await StorageService.setGuestLogin(false);

      _postLoginSetup();
      Get.offAllNamed(AppRoutes.dashboard);
    } on AppException catch (e) {
      dev.log('✖ AppException: ${e.message}', name: 'GoogleLogin');
      _showError(e.message);
    } on FirebaseAuthException catch (e) {
      dev.log(
        '✖ FirebaseAuthException: code=${e.code} msg=${e.message}',
        name: 'GoogleLogin',
      );
      _showError('Authentication error: ${e.message ?? "Please try again."}');
    } catch (e, st) {
      dev.log(
        '✖ Unexpected error: $e',
        name: 'GoogleLogin',
        error: e,
        stackTrace: st,
      );
      _showError('Google Sign In failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsGuest() async {
    isLoading.value = true;
    try {
      final user = await _repo.guestLogin();
      await StorageService.saveToken(user.accessToken!);
      if (user.refreshToken != null) {
        await StorageService.saveRefreshToken(user.refreshToken!);
      }
      await StorageService.saveUserId(user.id);
      await StorageService.setGuestLogin(true);
      AppManager.isLoginAsGuest = true;
      Get.offAllNamed(AppRoutes.dashboard);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Guest login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    isLoading.value = true;
    try {
      final user = await _repo.login(email.trim().toLowerCase(), password);
      await StorageService.saveToken(user.accessToken!);
      await StorageService.saveRefreshToken(user.refreshToken!);
      await StorageService.saveUserId(user.id);
      await StorageService.setLoginMethod('email');
      await StorageService.setGuestLogin(false);

      // Run post-login tasks (non-blocking — failures don't block navigation)
      _postLoginSetup();

      Get.offAllNamed(AppRoutes.dashboard);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Login failed. Please check your credentials.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _postLoginSetup() async {
    await _callFetchProfile();
    await _callRegisterDevice();
  }

  /// Call this after any social login (Google, Apple) to register the device.
  Future<void> registerDevice() => _callRegisterDevice();

  Future<void> _callFetchProfile() async {
    try {
      final user = await _repo.fetchProfile();
      await StorageService.setString(StorageKeys.fullname, user.fullName);
      await StorageService.setString(StorageKeys.username, user.username);
      dev.log('fetchProfile success — ${user.email}', name: 'AuthController');
    } catch (e) {
      dev.log('fetchProfile error — $e', name: 'AuthController');
    }
  }

  Future<void> _callRegisterDevice() async {
    try {
      var deviceId = StorageService.getDeviceId();
      if (deviceId == null) {
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await StorageService.saveDeviceId(deviceId);
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        dev.log(
          'registerDevice skipped — FCM token unavailable',
          name: 'AuthController',
        );
        return;
      }

      await _repo.registerDevice(
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceModel: Platform.operatingSystem,
        deviceId: deviceId,
        deviceToken: fcmToken,
      );
      dev.log('registerDevice success', name: 'AuthController');
    } catch (e) {
      dev.log('registerDevice error — $e', name: 'AuthController');
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _repo.forgotPassword(email.trim().toLowerCase());
      final message =
          response['message'] as String? ??
          'A verification code has been sent to your email.';
      _showSuccess(message);
      Get.toNamed(
        AppRoutes.forgotPasswordOtp,
        arguments: {'email': email.trim().toLowerCase()},
      );
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Failed to send reset code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyForgotPasswordOtp(String email, String otp) async {
    if (otp.length < 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }
    isLoading.value = true;
    try {
      await _repo.verifyForgotPasswordOtp(email, otp.trim());
      _showSuccess('OTP verified successfully.');
      Get.toNamed(AppRoutes.resetPassword, arguments: {'email': email});
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('OTP verification failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _repo.resetPassword(email, password);
      final message =
          response['message'] as String? ??
          'Password has been reset successfully.';
      _showSuccess(message);
      Get.offAllNamed(AppRoutes.login);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Password reset failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _repo.logout();
    } catch (_) {
      // Proceed with local logout even if API call fails
    } finally {
      await StorageService.clearAuth();
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.register);
    }
  }
}
