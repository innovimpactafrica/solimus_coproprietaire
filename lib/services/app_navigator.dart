// lib/services/app_navigator.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/auth/login.dart';
import 'auth_storage.dart';
import 'user_session.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isRedirecting = false;

  /// Gère l'expiration de session (401) : nettoie le stockage local et redirige vers LoginPage.
  static Future<void> handleSessionExpired() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    try {
      await AuthStorage.clear();
      await UserSession.instance.clearLocalPhoto();
    } catch (e) {
    }

    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
            duration: Duration(seconds: 4),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      } catch (_) {}
    }

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );

    Future.delayed(const Duration(seconds: 3), () {
      _isRedirecting = false;
    });
  }

  /// Vérifie la réponse HTTP et déclenche la redirection si le code est 401.
  static void checkResponse(http.Response response) {
    if (response.statusCode == 401) {
      handleSessionExpired();
      throw Exception('Session expirée. Redirection vers la page de connexion.');
    }
  }
}
