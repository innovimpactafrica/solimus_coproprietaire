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

  // ── Présence aux réunions ────────────────────────────────────────────────

  // Mémoire locale (synchrone) : meetingId → 'CONFIRMED' | 'PROXY:Nom Prenom'
  final Map<int, String> _meetingAttendance = {};

  /// Retourne la valeur stockée pour une réunion (null si non renseignée).
  String? getMeetingAttendance(int meetingId) => _meetingAttendance[meetingId];

  /// Enregistre la réponse de présence en mémoire et dans SharedPreferences.
  void setMeetingAttendance(int meetingId, String value) {
    _meetingAttendance[meetingId] = value;
    // Persistance asynchrone (fire-and-forget)
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString('meeting_attendance_$meetingId', value),
    );
  }

  /// Charge depuis SharedPreferences les réponses sauvegardées (à appeler au démarrage).
  Future<void> loadMeetingAttendances(List<int> meetingIds) async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in meetingIds) {
      final saved = prefs.getString('meeting_attendance_$id');
      if (saved != null) _meetingAttendance[id] = saved;
    }
  }
}
