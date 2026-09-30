import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey     = 'access_token';
  static const _userIdKey    = 'user_id';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey  = 'last_name';
  static const _emailKey     = 'email';
  static const _roleKey      = 'user_role';

  static Future<void> save({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    String? role,
  }) async {
    await _storage.write(key: _tokenKey,     value: token);
    await _storage.write(key: _userIdKey,    value: userId.toString());
    await _storage.write(key: _firstNameKey, value: firstName);
    await _storage.write(key: _lastNameKey,  value: lastName);
    await _storage.write(key: _emailKey,     value: email);
    if (role != null && role.isNotEmpty) {
      await _storage.write(key: _roleKey, value: role);
    }
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  static Future<String?> getFirstName() async {
    return _storage.read(key: _firstNameKey);
  }

  static Future<String?> getLastName() async {
    return _storage.read(key: _lastNameKey);
  }

  static Future<String?> getEmail() async {
    return _storage.read(key: _emailKey);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
