import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/login_response.dart';

String _extractApiError(http.Response response, String fallback) {
  try {
    final j = jsonDecode(response.body);
    if (j is Map) {
      return (j['message'] ?? j['error'] ?? j['detail'] ?? fallback).toString();
    }
    if (j is String && j.isNotEmpty) return j;
  } catch (_) {
    if (response.body.isNotEmpty) return response.body;
  }
  return fallback;
}

class AuthService {
  static Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required int residenceId,
    required int propertyId,
    String? profilePhotoUrl,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'role': 'Copropriétaire',
      'residenceId': residenceId,
      'propertyId': propertyId,
    };
    if (profilePhotoUrl != null) body['profilePhotoUrl'] = profilePhotoUrl;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Échec de l\'inscription'));
    }
  }

  static Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Code de vérification invalide'));
    }
  }

  static Future<void> setPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/set-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Échec de la création du mot de passe'));
    }
  }

  static Future<void> logout({required String token}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Échec de la déconnexion'));
    }
  }

  static Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Échec de la réinitialisation du mot de passe'));
    }
  }

  static Future<String> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailOrPhone': emailOrPhone, 'code': code}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Code de réinitialisation invalide'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['token'] as String;
  }

  static Future<void> forgotPassword({
    required String emailOrPhone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emailOrPhone': emailOrPhone}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Échec de l\'envoi du code de réinitialisation'));
    }
  }

  static Future<LoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractApiError(response, 'Identifiant ou mot de passe incorrect'));
    }

    return LoginResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
