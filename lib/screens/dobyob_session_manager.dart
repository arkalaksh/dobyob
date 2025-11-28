import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class DobYobSessionManager {
  static DobYobSessionManager? _instance;
  static SharedPreferences? _prefs;

  DobYobSessionManager._internal();

  // Singleton instance
  static Future<DobYobSessionManager> getInstance() async {
    _instance ??= DobYobSessionManager._internal();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Keys (DobYob साठी)
  static const String _keyUserId = 'dy_user_id';
  static const String _keyUserName = 'dy_user_name';
  static const String _keyEmail = 'dy_user_email';
  static const String _keyPhone = 'dy_user_phone';
  static const String _keyDeviceToken = 'dy_device_token';
  static const String _keyDeviceType = 'dy_device_type';
  static const String _keyIsLoggedIn = 'dy_is_logged_in';
  static const String _keyProfilePicture = 'dy_profile_picture';

  /// Login / registration नंतर user session save कर
  Future<void> saveUserSession({
    required int userId,
    required String name,
    required String email,
    required String phone, // "+91 9876..." string चालेल
    required String deviceToken,
    required String deviceType,
    String? profilePicture,
  }) async {
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

      if (profilePicture != null) {
        await _prefs!.setString(_keyProfilePicture, profilePicture);
      }

      if (kDebugMode) {
        print('✅ DobYob session saved for: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving DobYob session: $e');
      }
      rethrow;
    }
  }

  // -------- Getters --------

  Future<bool> isLoggedIn() async =>
      _prefs?.getBool(_keyIsLoggedIn) ?? false;

  Future<int?> getUserId() async => _prefs?.getInt(_keyUserId);

  Future<String?> getUserName() async =>
      _prefs?.getString(_keyUserName);

  Future<String?> getEmail() async =>
      _prefs?.getString(_keyEmail);

  Future<String?> getPhone() async =>
      _prefs?.getString(_keyPhone);

  Future<String?> getDeviceToken() async =>
      _prefs?.getString(_keyDeviceToken);

  Future<String?> getDeviceType() async =>
      _prefs?.getString(_keyDeviceType);

  Future<String?> getProfilePicture() async =>
      _prefs?.getString(_keyProfilePicture);

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

  // -------- Updates (optional) --------

  Future<void> updateUserName(String name) async {
    await _prefs!.setString(_keyUserName, name);
  }

  Future<void> updateProfilePicture(String url) async {
    await _prefs!.setString(_keyProfilePicture, url);
  }

  // -------- Logout / Clear --------

  Future<void> clearSession() async {
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
      if (kDebugMode) {
        print('✅ DobYob session cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing DobYob session: $e');
      }
      rethrow;
    }
  }
}
