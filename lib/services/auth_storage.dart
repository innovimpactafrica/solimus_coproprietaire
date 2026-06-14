import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _emailKey = 'email';

  static Future<void> save({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
