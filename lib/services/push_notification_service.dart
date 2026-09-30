import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_storage.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
  }
}

class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._();
  PushNotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request permission for push notifications
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
      }

      // Get FCM Token (avec gestion du délai APNS sur iOS / Simulateur)
      String? fcmToken;
      try {
        if (Platform.isIOS) {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) {
            fcmToken = await messaging.getToken();
          } else if (kDebugMode) {
          }
        } else {
          fcmToken = await messaging.getToken();
        }
      } catch (tokenErr) {
        if (kDebugMode) {
        }
      }

      if (kDebugMode && fcmToken != null) {
      }

      if (fcmToken != null) {
        await _registerDeviceTokenWithBackend(fcmToken);
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
        }
        await _registerDeviceTokenWithBackend(newToken);
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
        }
      });

      // Message click listener when app opens from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
        }
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerDeviceTokenWithBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  static Future<void> _registerDeviceTokenWithBackend(String token) async {
    try {
      final authToken = await AuthStorage.getToken();
      if (authToken == null || authToken.isEmpty) return;

      final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';

      final response = await ApiClient.post(
        Uri.parse('${ApiConfig.baseUrl}/api/account/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'deviceToken': token,
          'deviceType': deviceType,
        }),
      );

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }
}
