import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  StorageKeys._();

  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'myId';
  static const String isGuestLogin = 'is_guest_login';
  static const String loginMethod = 'login_method';
  static const String appLocale = 'app_locale';
  static const String deviceId = 'device_id';
  static const String fullname = 'fullname';
  static const String username = 'username';
}

class StorageService {
  StorageService._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'StorageService.init() must be called before use');
    return _prefs!;
  }

  // Token
  static String? getToken() => _prefs?.getString(StorageKeys.token);
  static Future<void> saveToken(String v) async => _instance.setString(StorageKeys.token, v);

  // Refresh token
  static String? getRefreshToken() => _prefs?.getString(StorageKeys.refreshToken);
  static Future<void> saveRefreshToken(String v) async => _instance.setString(StorageKeys.refreshToken, v);

  // User ID
  static String? getUserId() => _prefs?.getString(StorageKeys.userId);
  static Future<void> saveUserId(String v) async => _instance.setString(StorageKeys.userId, v);

  // Guest login
  static bool isGuestLogin() => _prefs?.getBool(StorageKeys.isGuestLogin) ?? false;
  static Future<void> setGuestLogin(bool v) async => _instance.setBool(StorageKeys.isGuestLogin, v);

  // Login method
  static String? getLoginMethod() => _prefs?.getString(StorageKeys.loginMethod);
  static Future<void> setLoginMethod(String v) async => _instance.setString(StorageKeys.loginMethod, v);

  // Device ID (persisted across sessions)
  static String? getDeviceId() => _prefs?.getString(StorageKeys.deviceId);
  static Future<void> saveDeviceId(String v) async => _instance.setString(StorageKeys.deviceId, v);

  // Generic
  static String? getString(String key) => _prefs?.getString(key);
  static Future<void> setString(String key, String value) async => _instance.setString(key, value);
  static bool? getBool(String key) => _prefs?.getBool(key);
  static Future<void> setBool(String key, bool value) async => _instance.setBool(key, value);

  static Future<void> clearAuth() async {
    await _instance.remove(StorageKeys.token);
    await _instance.remove(StorageKeys.refreshToken);
    await _instance.remove(StorageKeys.userId);
    await _instance.remove(StorageKeys.isGuestLogin);
    await _instance.remove(StorageKeys.loginMethod);
  }
}
