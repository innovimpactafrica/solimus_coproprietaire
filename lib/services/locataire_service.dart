import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/intervention_model.dart';
import '../models/locataire_models.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_storage.dart';

class LocataireService {
  // Délai simulé pour les méthodes mock restantes
  static const _delay = Duration(milliseconds: 400);

  /// Récupère le profil du locataire connecté (GET /api/tenant/profile).
  static Future<LocataireProfile> getProfile() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/profile';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le profil locataire (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return LocataireProfile.fromJson(json);
  }

  /// Récupère le dashboard du locataire connecté (GET /api/tenant/dashboard).
  static Future<TenantDashboardModel> getDashboard() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/dashboard';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le dashboard locataire (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TenantDashboardModel.fromJson(json);
  }

  /// Récupère le bien loué du locataire connecté (GET /api/tenant/my-property).
  static Future<TenantPropertyModel> getMyProperty() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/my-property';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le bien loué (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TenantPropertyModel.fromJson(json);
  }

  /// Récupère la liste des parties communes de la résidence du locataire (GET /api/tenant/common-facilities).
  static Future<List<CommonFacilityModel>> getTenantCommonFacilities() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/common-facilities';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les parties communes (${response.statusCode}): ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => CommonFacilityModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère la liste des demandes de travaux du locataire (GET /api/tenant/interventions).
  static Future<InterventionsResponse> getTenantInterventions({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/interventions')
        .replace(queryParameters: queryParams);
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les demandes de travaux (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return InterventionsResponse.fromJson(json);
  }

  /// Crée une demande de travaux pour le locataire (POST /api/tenant/interventions).
  static Future<void> createTenantIntervention({
    required String title,
    required String description,
    required int specialtyId,
    required String locationType,
    required String urgencyLevel,
    int? commonFacilityId,
    List<String> photos = const [],
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'title': title,
      'description': description,
      'specialtyId': specialtyId.toString(),
      'locationType': locationType,
      'urgencyLevel': urgencyLevel,
      if (commonFacilityId != null) 'commonFacilityId': commonFacilityId.toString(),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/interventions')
        .replace(queryParameters: queryParams);

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }
    for (final p in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', p));
    }

    final response = await ApiClient.sendMultipart(request);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création travaux (${response.statusCode}): $detail');
    }
  }

  /// Récupère le détail d'une demande de travaux du locataire (GET /api/tenant/interventions/{interventionId}).
  static Future<InterventionDetailModel> getTenantInterventionDetail(int id) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/interventions/$id';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le détail des travaux (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return InterventionDetailModel.fromJson(json);
  }

  // ignore: unused_field
  static final List<SignalementLocataire> _mockSignalements = [
    SignalementLocataire(
      id: 'sig-001',
      titre: 'Fuite d\'eau salle de bain',
      description:
          'Une fuite importante au niveau du robinet de la salle de bain provoque des dégâts au sol. La situation empire depuis 2 jours.',
      date: DateTime(2026, 7, 28),
      priorite: SignalementPriorite.haute,
      statut: SignalementStatut.enCours,
    ),
    SignalementLocataire(
      id: 'sig-002',
      titre: 'Ampoule couloir grillée',
      description:
          'L\'ampoule du couloir principal est hors service depuis une semaine. La zone est mal éclairée la nuit.',
      date: DateTime(2026, 7, 15),
      priorite: SignalementPriorite.faible,
      statut: SignalementStatut.resolu,
    ),
    SignalementLocataire(
      id: 'sig-003',
      titre: 'Bruit excessif voisin du dessus',
      description:
          'Des bruits de pas et de musique forte sont régulièrement audibles depuis l\'appartement du dessus, notamment la nuit.',
      date: DateTime(2026, 8, 1),
      priorite: SignalementPriorite.moyenne,
      statut: SignalementStatut.enAttente,
    ),
    SignalementLocataire(
      id: 'sig-004',
      titre: 'Porte d\'entrée immeuble défectueuse',
      description:
          'Le digicode de la porte d\'entrée principale ne fonctionne plus correctement. Certains codes ne sont pas reconnus.',
      date: DateTime(2026, 8, 3),
      priorite: SignalementPriorite.haute,
      statut: SignalementStatut.enAttente,
    ),
    SignalementLocataire(
      id: 'sig-005',
      titre: 'Ascenseur en panne',
      description:
          'L\'ascenseur de la résidence est hors service depuis ce matin. Plusieurs résidents âgés sont concernés.',
      date: DateTime(2026, 8, 4),
      priorite: SignalementPriorite.haute,
      statut: SignalementStatut.enCours,
    ),
  ];

  /// Récupère la liste des signalements du locataire (GET /api/tenant/signalements).
  static Future<List<SignalementLocataire>> getSignalements({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/signalements')
        .replace(queryParameters: queryParams);
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les signalements (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List? ?? [];
    return content
        .map((e) => SignalementLocataire.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Récupère la réponse paginée complète des signalements.
  static Future<TenantSignalementsResponse> getSignalementsResponse({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/signalements')
        .replace(queryParameters: queryParams);
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les signalements (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TenantSignalementsResponse.fromJson(json);
  }

  /// Récupère le détail complet d'un signalement du locataire (GET /api/tenant/signalements/{id}).
  static Future<TenantSignalementDetailModel> getSignalementDetail(int id) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/signalements/$id';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le détail du signalement (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TenantSignalementDetailModel.fromJson(json);
  }

  /// Crée un nouveau signalement pour le locataire (POST /api/tenant/signalements).
  static Future<void> createSignalement({
    required String title,
    required String description,
    required String locationType,
    required String urgencyLevel,
    int? commonFacilityId,
    List<String> photos = const [],
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'title': title,
      'description': description,
      'locationType': locationType,
      'urgencyLevel': urgencyLevel,
      if (commonFacilityId != null) 'commonFacilityId': commonFacilityId.toString(),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/signalements')
        .replace(queryParameters: queryParams);

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }
    for (final p in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', p));
    }

    final response = await ApiClient.sendMultipart(request);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création signalement (${response.statusCode}): $detail');
    }
  }

  /// Crée un nouveau signalement pour le locataire (compatibilité).
  static Future<SignalementLocataire> addSignalement({
    required String titre,
    required String description,
    required SignalementPriorite priorite,
    List<String> photos = const [],
    String locationType = 'APPARTEMENT',
    int? commonFacilityId,
  }) async {
    String urgencyStr = 'MOYEN';
    if (priorite == SignalementPriorite.haute) urgencyStr = 'URGENT';
    if (priorite == SignalementPriorite.faible) urgencyStr = 'FAIBLE';

    await createSignalement(
      title: titre,
      description: description,
      locationType: locationType,
      urgencyLevel: urgencyStr,
      commonFacilityId: commonFacilityId,
      photos: photos,
    );

    return SignalementLocataire(
      id: 'sig-${DateTime.now().millisecondsSinceEpoch}',
      titre: titre,
      description: description,
      date: DateTime.now(),
      priorite: priorite,
      statut: SignalementStatut.enAttente,
      photoUrls: photos,
    );
  }

  /// Récupère la liste des travaux de la résidence.
  /// Remplacer par : GET /api/locataire/travaux
  /// Récupère la liste des travaux de la résidence du locataire (GET /api/tenant/interventions).
  static Future<List<TravauxLocataire>> getTravaux() async {
    try {
      final res = await getTenantInterventions();
      if (res.interventions.isEmpty) return [];

      return res.interventions.map((item) {
        TravauxStatut s = TravauxStatut.planifie;
        final st = item.status.toUpperCase();
        if (st == 'STARTED' || st == 'IN_PROGRESS') {
          s = TravauxStatut.enCours;
        } else if (st == 'FINISHED' || st == 'FINAL_VALIDATION' || st == 'RESOLVED') {
          s = TravauxStatut.termine;
        } else if (st == 'CANCELLED') {
          s = TravauxStatut.annule;
        }

        DateTime? dateP;
        if (item.createdAt != null && item.createdAt!.isNotEmpty) {
          dateP = DateTime.tryParse(item.createdAt!);
          if (dateP == null) {
            final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})(?:\s+(\d{2}):(\d{2})(?::(\d{2}))?)?');
            final match = regex.firstMatch(item.createdAt!);
            if (match != null) {
              final day = int.parse(match.group(1)!);
              final month = int.parse(match.group(2)!);
              final year = int.parse(match.group(3)!);
              final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
              final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
              final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;
              dateP = DateTime(year, month, day, hour, minute, second);
            }
          }
        }
        dateP ??= DateTime.now();

        return TravauxLocataire(
          id: item.id.toString(),
          titre: item.title,
          description: item.location,
          datePrevue: dateP,
          statut: s,
          categorie: TravauxCategorie.autre,
          entreprise: item.fromTenant ? 'Locataire' : 'Copropriétaire',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  /// Récupère la liste des notifications du locataire depuis l'API.
  static Future<List<LocataireNotification>> getNotifications() async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/dashboard/notifications')
        .replace(queryParameters: {'page': '0', 'size': '20'});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // En cas d'erreur, retourner une liste vide plutôt que planquer
      return [];
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : (decoded['content'] as List? ?? decoded['notifications'] as List? ?? []);
    return list.map((e) => LocataireNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Compte le nombre de notifications non lues.
  static Future<int> getUnreadNotificationCount() async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/tenant/dashboard/notifications/unread-count');
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 0;
    }

    final decoded = jsonDecode(response.body);
    return decoded is int ? decoded : (decoded['count'] as int? ?? 0);
  }

  /// Marque toutes les notifications comme lues.
  static Future<void> markAllNotificationsRead() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/tenant/dashboard/notifications/mark-all-read'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur lors du marquage des notifications comme lues (${response.statusCode})');
    }
  }

  /// Crée une notification de bienvenue pour un nouveau profil locataire.
  static Future<void> createWelcomeNotification() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/tenant/dashboard/notifications/welcome'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': 'Bienvenue sur Solimus',
        'body': 'Bienvenue dans votre nouvel espace Locataire ! Suivez vos réclamations et travaux en temps réel.',
      }),
    );

    // Ne pas lancer d'erreur si l'endpoint n'existe pas encore
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Silencieux - l'endpoint peut ne pas être implémenté côté backend
    }
  }

  /// Active/Désactive les notifications du locataire (PUT /api/tenant/profile/notifications)
  static Future<void> toggleNotifications() async {
    final token = await AuthStorage.getToken();
    final urls = [
      '${ApiConfig.baseUrl}/api/tenant/profile/notifications',
      '${ApiConfig.baseUrl}/api/account/notification-settings',
    ];

    for (final url in urls) {
      try {
        final response = await ApiClient.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return; // Succès
        }
      } catch (e) {
      }
    }

    // Si le backend n'a pas encore créé l'endpoint locataire, loguer proprement sans faire crasher l'UI
  }

  /// Modifie le mot de passe du locataire (PUT /api/tenant/profile/change-password).
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/tenant/profile/change-password';
    final response = await ApiClient.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Mot de passe actuel incorrect ou confirmation invalide';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['message'] != null && body['message'].toString().isNotEmpty) {
          errorMessage = body['message'].toString();
        } else if (body['details'] is List && (body['details'] as List).isNotEmpty) {
          errorMessage = (body['details'] as List).first.toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
