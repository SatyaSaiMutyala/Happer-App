import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/features/auth/data/repositories/auth_repository.dart';

/// Keeps the session alive without the user having to log in again.
///
/// The backend issues a 24h access token and a 30d refresh token, but exposes
/// **no endpoint to redeem the refresh token** — so a classic refresh call is
/// not available to us. What it does expose is `google-login` / `apple-login`,
/// which accept a Firebase ID token and verify it with Firebase Admin.
///
/// Firebase keeps its own long-lived session on the device and can mint a fresh
/// ID token at any time, so for social logins we can silently obtain one, trade
/// it at those endpoints, and get a new access token. Net effect for the user is
/// the same as a refresh token: they are never logged out.
///
/// Email/password logins have no silent path (that would mean storing the
/// password on the device), so [renew] returns false for them and the caller
/// falls back to its normal session-expired handling.
class TokenRefreshService {
  TokenRefreshService._();

  static final TokenRefreshService instance = TokenRefreshService._();

  /// Single-flight guard: if several requests get a 401 at once they must share
  /// one renewal instead of each firing their own.
  Future<bool>? _inFlight;

  bool get canRenewSilently {
    final method = StorageService.getLoginMethod();
    return method == 'google' || method == 'apple';
  }

  Future<bool> renew() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final future = _renew();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<bool> _renew() async {
    final method = StorageService.getLoginMethod();
    if (method != 'google' && method != 'apple') {
      debugPrint('[TokenRefresh] no silent path for loginMethod=$method');
      return false;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[TokenRefresh] no Firebase user — cannot renew');
        return false;
      }

      // force: true asks Firebase for a brand new ID token rather than the
      // cached (and by now expired) one.
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[TokenRefresh] Firebase returned an empty ID token');
        return false;
      }

      final repo = AuthRepository(ApiClient());
      final refreshed = method == 'google'
          ? await repo.googleLogin(idToken: idToken)
          : await repo.appleLogin(idToken: idToken);

      final accessToken = refreshed.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('[TokenRefresh] backend returned no access token');
        return false;
      }

      await StorageService.saveToken(accessToken);
      final newRefresh = refreshed.refreshToken;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await StorageService.saveRefreshToken(newRefresh);
      }
      await StorageService.saveUserId(refreshed.id);
      debugPrint('[TokenRefresh] session renewed via $method');
      return true;
    } catch (e) {
      debugPrint('[TokenRefresh] renewal failed: $e');
      return false;
    }
  }
}
