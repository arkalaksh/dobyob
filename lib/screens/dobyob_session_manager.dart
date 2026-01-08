import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class DobYobSessionManager {
  static DobYobSessionManager? _instance;
  static SharedPreferences? _prefs;

  DobYobSessionManager._internal();

  // BASE URL (absolute path generation साठी)
  static const String BASE_URL = "https://dobyob.arkalaksh.com/";

  // ✅ NEW: profile pic update झालं की app मधल्या इतर screens ला signal देण्यासाठी
  // value change -> listeners trigger
  static final ValueNotifier<int> profilePicVersion = ValueNotifier<int>(0);

  // Convert relative path → absolute URL
  static String resolveUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    if (path.startsWith("http")) return path; // already full url
    return BASE_URL + path;
  }

  // Singleton instance
  static Future<DobYobSessionManager> getInstance() async {
    _instance ??= DobYobSessionManager._internal();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Keys
  static const String _keyUserId = 'dy_user_id';
  static const String _keyUserName = 'dy_user_name';
  static const String _keyEmail = 'dy_user_email';
  static const String _keyPhone = 'dy_user_phone';
  static const String _keyDeviceToken = 'dy_device_token';
  static const String _keyDeviceType = 'dy_device_type';
  static const String _keyIsLoggedIn = 'dy_is_logged_in';
  static const String _keyProfilePicture = 'dy_profile_picture';

  /// Save user session
  Future<void> saveUserSession({
    required int userId,
    required String name,
    required String email,
    required String phone,
    required String deviceToken,
    required String deviceType,
    String? profilePicture,
  }) async {
    await _ensurePrefs();

    try {
      await Future.wait([
        _prefs!.setInt(_keyUserId, userId),
        _prefs!.setString(_keyUserName, name),
        _prefs!.setString(_keyEmail, email),
        _prefs!.setString(_keyPhone, phone),
        _prefs!.setString(_keyDeviceToken, deviceToken),
        _prefs!.setString(_keyDeviceType, deviceType),
        _prefs!.setBool(_keyIsLoggedIn, true),
      ]);

      if (profilePicture != null && profilePicture.isNotEmpty) {
        final fullUrl = resolveUrl(profilePicture);
        await _prefs!.setString(_keyProfilePicture, fullUrl);

        // ✅ NEW: session save मध्ये pic set होत असेल तर पण notify
        profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ DobYob session saved for: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ Error saving DobYob session: $e');
      }
      rethrow;
    }
  }

  // -------- Getters --------
  Future<bool> isLoggedIn() async => _prefs?.getBool(_keyIsLoggedIn) ?? false;

  Future<int?> getUserId() async => _prefs?.getInt(_keyUserId);

  Future<String?> getUserName() async => _prefs?.getString(_keyUserName);

  Future<String?> getEmail() async => _prefs?.getString(_keyEmail);

  Future<String?> getPhone() async => _prefs?.getString(_keyPhone);

  Future<String?> getDeviceToken() async => _prefs?.getString(_keyDeviceToken);

  Future<String?> getDeviceType() async => _prefs?.getString(_keyDeviceType);

  Future<String?> getProfilePicture() async => _prefs?.getString(_keyProfilePicture);

  Future<Map<String, dynamic>> getUserData() async => {
        'user_id': await getUserId(),
        'name': await getUserName(),
        'email': await getEmail(),
        'phone': await getPhone(),
        'device_token': await getDeviceToken(),
        'device_type': await getDeviceType(),
        'profile_picture': await getProfilePicture(),
        'is_logged_in': await isLoggedIn(),
      };

  // -------- Updates --------
  Future<void> updateUserName(String name) async {
    await _ensurePrefs();
    await _prefs!.setString(_keyUserName, name);
  }

  Future<void> updateProfilePicture(String url) async {
    await _ensurePrefs();

    final fullUrl = resolveUrl(url);
    await _prefs!.setString(_keyProfilePicture, fullUrl);

    // ✅ NEW: हाच मुख्य change — feed/other screens ला लगेच कळेल
    profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;
  }

  // -------- Logout / Clear --------
  Future<void> clearSession() async {
    await _ensurePrefs();

    try {
      await Future.wait([
        _prefs!.remove(_keyUserId),
        _prefs!.remove(_keyUserName),
        _prefs!.remove(_keyEmail),
        _prefs!.remove(_keyPhone),
        _prefs!.remove(_keyDeviceToken),
        _prefs!.remove(_keyDeviceType),
        _prefs!.remove(_keyProfilePicture),
        _prefs!.setBool(_keyIsLoggedIn, false),
      ]);

      // ✅ optional: reset notifier
      profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;

      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ DobYob session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ Error clearing DobYob session: $e');
      }
      rethrow;
    }
  }

  Future getUserSession() async {}
}