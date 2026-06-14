import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  // Chemin local vers la photo de profil (Image.file — pas besoin d'auth)
  final ValueNotifier<String?> localPhotoPath = ValueNotifier(null);

  static const _photoFileName = 'profile_photo.jpg';
  static const _prefKey = 'has_local_photo';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) == true) {
      // Reconstruire le chemin frais à chaque démarrage (évite les UUID iOS obsolètes)
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$_photoFileName';
      if (File(path).existsSync()) {
        localPhotoPath.value = path;
      } else {
        await prefs.remove(_prefKey);
      }
    }
  }

  /// Copie la photo depuis le répertoire temp vers le stockage permanent de l'app.
  Future<void> saveLocalPhoto(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/$_photoFileName';
    await File(tempPath).copy(dest);
    localPhotoPath.value = dest;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  Future<void> clearLocalPhoto() async {
    localPhotoPath.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
