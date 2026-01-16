import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dobyob_1/services/api_service.dart';

class DobYobSessionManager {
  static DobYobSessionManager? _instance;
  static SharedPreferences? _prefs;

  DobYobSessionManager._internal();

  // BASE URL (absolute path generation साठी)
  static const String BASE_URL = "https://dobyob.arkalaksh.com/";

  // profile pic update झालं की app मधल्या इतर screens ला signal देण्यासाठी
  static final ValueNotifier<int> profilePicVersion = ValueNotifier<int>(0);

  // DOB support for priority feed
  static const String _keyDob = 'dy_user_dob';

  // Keys
  static const String _keyUserId = 'dy_user_id';
  static const String _keyUserName = 'dy_user_name';
  static const String _keyEmail = 'dy_user_email';
  static const String _keyPhone = 'dy_user_phone';
  static const String _keyDeviceToken = 'dy_device_token';
  static const String _keyDeviceType = 'dy_device_type';
  static const String _keyIsLoggedIn = 'dy_is_logged_in';
  static const String _keyProfilePicture = 'dy_profile_picture';

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

  /// Save user session (DOB add केलं)
  Future<void> saveUserSession({
    required int userId,
    required String name,
    required String email,
    required String phone,
    String? dob, // DD-MM-YYYY
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

      // DOB save
      if (dob != null && dob.isNotEmpty) {
        await _prefs!.setString(_keyDob, dob);
      }

      // profile picture
      if (profilePicture != null && profilePicture.isNotEmpty) {
        final fullUrl = resolveUrl(profilePicture);
        await _prefs!.setString(_keyProfilePicture, fullUrl);
        profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;
      }

      if (kDebugMode) {
        print('✅ DobYob session saved for: $name, DOB: $dob');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving DobYob session: $e');
      }
      rethrow;
    }
  }

  // -------- Getters --------
  Future<bool> isLoggedIn() async {
    await _ensurePrefs();
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<int?> getUserId() async {
    await _ensurePrefs();
    return _prefs?.getInt(_keyUserId);
  }

  Future<String?> getUserName() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyUserName);
  }

  Future<String?> getEmail() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyEmail);
  }

  Future<String?> getPhone() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyPhone);
  }

  Future<String?> getDob() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyDob);
  }

  Future<void> setDob(String dob) async {
    await _ensurePrefs();
    await _prefs!.setString(_keyDob, dob);
    if (kDebugMode) print('✅ DOB saved: $dob');
  }

  Future<String?> getDeviceToken() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyDeviceToken);
  }

  Future<String?> getDeviceType() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyDeviceType);
  }

  Future<String?> getProfilePicture() async {
    await _ensurePrefs();
    return _prefs?.getString(_keyProfilePicture);
  }

  Future<Map<String, dynamic>> getUserData() async => {
        'user_id': await getUserId(),
        'name': await getUserName(),
        'email': await getEmail(),
        'phone': await getPhone(),
        'dob': await getDob(),
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

  Future<void> updateDob(String dob) async {
    await _ensurePrefs();
    await _prefs!.setString(_keyDob, dob);
    if (kDebugMode) print('✅ DOB updated: $dob');
  }

  Future<void> updateProfilePicture(String url) async {
    await _ensurePrefs();

    final fullUrl = resolveUrl(url);
    await _prefs!.setString(_keyProfilePicture, fullUrl);
    profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;
  }

  // -------- Logout / Clear --------
// Replace clearSession() method with this:
Future<void> clearSession() async {
  await _ensurePrefs();

  try {
    // 🔥 SELECTIVE CLEAR - Session keys only
    final sessionKeys = [
      _keyUserId,
      _keyUserName, 
      _keyEmail,
      _keyPhone,
      _keyDob,
      _keyDeviceToken,
      _keyDeviceType,
      _keyProfilePicture,
      _keyIsLoggedIn,
    ];

    for (String key in sessionKeys) {
      await _prefs!.remove(key);
    }

    // Profile pic version reset
    profilePicVersion.value = DateTime.now().millisecondsSinceEpoch;

    if (kDebugMode) {
      print('✅ DobYob session completely cleared (${sessionKeys.length} keys)');
    }
  } catch (e) {
    if (kDebugMode) print('❌ Error clearing DobYob session: $e');
    rethrow;
  }
}



  // ✅ UPDATED: Backend session validation
  // - server status:success => logged in
  // - server status:invalid => logout (clearSession)
  // - server status:error/unknown OR network exception => keep logged in (offline-safe)
  Future<bool> validateSession() async {
    await _ensurePrefs();

    final localLoggedIn = _prefs?.getBool(_keyIsLoggedIn) ?? false;
    final userId = _prefs?.getInt(_keyUserId);

    if (!localLoggedIn || userId == null || userId <= 0) {
      await clearSession();
      return false;
    }

    try {
      final res = await ApiService().checkSession(userId);
      if (kDebugMode) print("🔍 SESSION VALIDATION: $res");

      final status = (res['status'] ?? '').toString();

      if (status == 'invalid') {
        await clearSession();
        return false;
      }

      if (status == 'success') {
        return true;
      }

      // status == 'error' किंवा काही unexpected -> logout नको
      return true;
    } catch (e) {
      if (kDebugMode) print("🔍 validateSession exception: $e");
      return true;
    }
  }
}
