import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_config.dart';
import 'auth_storage.dart';
import '../models/charge_model.dart';
import '../models/dashboard_model.dart';
import '../models/intervention_model.dart';
import '../models/meeting_model.dart';
import '../models/document_model.dart';
import '../models/profile_model.dart';
import '../models/property_model.dart';
import '../models/residence_model.dart';
import '../models/subscription_models.dart';

class CoOwnerService {
  static Future<ChargePaymentResponse> payAcompte({
    required int interventionId,
    required double montant,
    required String methode,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/deposit'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      // Corps identique à Swagger
      body: jsonEncode({'montant': montant, 'methode': methode}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur paiement acompte (${response.statusCode}): $detail');
    }

    return ChargePaymentResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<ResidenceModel>> getChargeResidences() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/residences'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les résidences (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ResidenceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<TravauManualResidence>> getInterventionResidences() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/travaux-manual/residences';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les résidences (${response.statusCode}): ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => TravauManualResidence.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<PropertyModel>> getInterventionProperties(int residenceId) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/travaux-manual/residences/$residenceId/properties';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les biens (${response.statusCode}): ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
  }


  static Future<List<SpecialtyModel>> getSpecialties() async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/travaux/specialties';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les spécialités (${response.statusCode})');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<CommonFacilityModel>> getCommonFacilities(int residenceId) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/travaux-manual/residences/$residenceId/common-facilities';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les parties communes (${response.statusCode})');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => CommonFacilityModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<NearbyProviderModel>> getNearbyProviders(int specialtyId) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/nearby-providers')
        .replace(queryParameters: {'specialtyId': specialtyId.toString()});

    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les prestataires (${response.statusCode}): ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => NearbyProviderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<BalanceSummaryModel> getBalanceSummary(int interventionId) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/balance-summary'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le récapitulatif (${response.statusCode}): ${response.body}');
    }

    return BalanceSummaryModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ChargePaymentResponse> validerSolde({
    required int interventionId,
    required String methode,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/balance'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      // Corps identique à Swagger
      body: jsonEncode({'methode': methode}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur validation solde (${response.statusCode}): $detail');
    }

    return ChargePaymentResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<QuoteModel>> getQuotes(int interventionId, {int page = 0, int size = 50}) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/quotes')
        .replace(queryParameters: {'page': page.toString(), 'size': size.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les devis (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : (decoded['content'] as List? ?? []);
    return list.map((e) => QuoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<QuoteModel> getQuoteDetail(int interventionId, int quoteId) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/quotes/$quoteId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le devis (${response.statusCode}): ${response.body}');
    }

    return QuoteModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<String> acceptQuote({
    required int interventionId,
    required int quoteId,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/quotes/$quoteId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur acceptation devis (${response.statusCode}): $detail');
    }

    return response.body;
  }

  static Future<String> createReview({
    required int interventionId,
    required int rating,
    String? comment,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux/interventions/$interventionId/review'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rating': rating, if (comment != null) 'comment': comment}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création avis (${response.statusCode}): $detail');
    }

    return response.body;
  }

  static Future<InterventionDetailModel> createIntervention({
    required String title,
    required String description,
    required int residenceId,
    int? propertyId,
    int? commonFacilityId,
    required int specialtyId,
    required String locationType,
    required String urgencyLevel,
    List<String> photos = const [],
  }) async {
    final token = await AuthStorage.getToken();

    // Tous les paramètres sont en query string, les photos en multipart body
    final queryParams = <String, String>{
      'title': title,
      'description': description,
      'residenceId': residenceId.toString(),
      'specialtyId': specialtyId.toString(),
      'locationType': locationType,
      'urgencyLevel': urgencyLevel,
      if (propertyId != null) 'propertyId': propertyId.toString(),
      if (commonFacilityId != null) 'commonFacilityId': commonFacilityId.toString(),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux-manual/interventions')
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
        detail = j['message']?.toString() ?? j['error']?.toString() ?? j['detail']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création intervention (${response.statusCode}): $detail');
    }

    if (response.body.trim().isEmpty) {
      return InterventionDetailModel(
          id: 0, title: '', status: 'PENDING', photoUrls: [], timeline: []);
    }
    return InterventionDetailModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<InterventionDetailModel> getInterventionDetail(int id) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/travaux-manual/interventions/$id';
    final response = await ApiClient.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger l\'intervention (${response.statusCode}): ${response.body}');
    }

    return InterventionDetailModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<InterventionsResponse> getInterventions({
    int page = 0,
    int size = 10,
    String? status,
    String? search,
    int? residenceId,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (residenceId != null) 'residenceId': residenceId.toString(),
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/travaux-manual/interventions')
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
      throw Exception('Impossible de charger les interventions (${response.statusCode}): ${response.body}');
    }

    return InterventionsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<DashboardProperty>> getDashboardProperties() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/properties'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dashboard properties (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => DashboardProperty.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<DashboardHeader> getDashboardHeader() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/header'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dashboard header (${response.statusCode}): ${response.body}');
    }
    return DashboardHeader.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<DashboardKpis> getDashboardKpis(int residenceId) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/kpis')
        .replace(queryParameters: {'residenceId': residenceId.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dashboard KPIs (${response.statusCode}): ${response.body}');
    }
    return DashboardKpis.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<DashboardNotificationsResponse> getDashboardNotifications({int page = 0, int size = 20}) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/notifications')
        .replace(queryParameters: {'page': page.toString(), 'size': size.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dashboard notifications (${response.statusCode}): ${response.body}');
    }
    return DashboardNotificationsResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> markAllNotificationsRead() async {
    final token = await AuthStorage.getToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/notifications/mark-all-read'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Mark all read (${response.statusCode}): ${response.body}');
    }
  }

  static Future<List<DashboardPendingCharge>> getDashboardPendingCharges(int residenceId) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/pending-charges')
        .replace(queryParameters: {'residenceId': residenceId.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Pending charges (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => DashboardPendingCharge.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<MeetingModel>> getDashboardUpcomingMeetings(int residenceId) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard/upcoming-meetings')
        .replace(queryParameters: {'residenceId': residenceId.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upcoming meetings (${response.statusCode}): ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<ResidenceModel>> getPublicResidences() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/coowner/residences'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ResidenceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<PropertyModel>> getPublicProperties(int residenceId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/coowner/residences/$residenceId/properties'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<ResidenceModel>> getResidences() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/residences'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les résidences (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : (decoded['content'] as List? ?? decoded['residences'] as List? ?? []);
    return list
        .map((e) => ResidenceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<PropertyModel>> getProperties(int residenceId) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/coowner/residences/$residenceId/properties'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les appartements (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : (decoded['content'] as List? ?? decoded['properties'] as List? ?? []);
    return list
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<MeetingDetailModel> getMeetingDetail(int meetingId, {int documentPage = 0, int documentSize = 10}) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/meetings/$meetingId')
        .replace(queryParameters: {
      'documentPage': documentPage.toString(),
      'documentSize': documentSize.toString(),
    });
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le détail de la réunion (${response.statusCode})');
    }

    return MeetingDetailModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Déclarer sa présence physique à une réunion (POST /api/owner/meetings/{meetingId}/mark-present)
  static Future<void> markMeetingPresent(int meetingId) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/meetings/$meetingId/mark-present';
    final response = await ApiClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Erreur lors de l\'enregistrement de la présence (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// Donner procuration à un mandataire pour une réunion (POST /api/owner/meetings/{meetingId}/procuration)
  static Future<void> giveMeetingProxy(int meetingId, String mandataireName) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/owner/meetings/$meetingId/procuration';
    final response = await ApiClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'mandataireName': mandataireName,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Erreur lors de l\'enregistrement de la procuration (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          msg = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<int> getUpcomingMeetingsCount() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/meetings/upcoming/count'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de récupérer le nombre de réunions à venir');
    }

    return int.tryParse(response.body.trim()) ?? 0;
  }

  static Future<Map<String, List<MeetingModel>>> getMeetingsCalendar({
    required int year,
    required int month,
  }) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/meetings/calendar/month')
        .replace(queryParameters: {
      'year': year.toString(),
      'month': month.toString(),
    });
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le calendrier (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final byDate = decoded['meetingsByDate'] as Map<String, dynamic>? ?? {};
    return byDate.map((date, list) => MapEntry(
      date,
      (list as List).map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList(),
    ));
  }

  static Future<({List<MeetingModel> meetings, int upcomingCount, int totalPages})> getMeetings({
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/meetings')
        .replace(queryParameters: {'page': page.toString(), 'size': size.toString()});
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les réunions (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final list = decoded['meetings'] as List? ?? [];
    return (
      meetings: list.map((e) => MeetingModel.fromJson(e as Map<String, dynamic>)).toList(),
      upcomingCount: (decoded['upcomingCount'] as num?)?.toInt() ?? 0,
      totalPages: (decoded['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  static Future<ChargesResponse> getCharges({
    int page = 0,
    int size = 20,
    String? status,
    String? search,
    String? type,
    int? residenceId,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null) 'type': type,
      if (residenceId != null) 'residenceId': residenceId.toString(),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges')
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
      throw Exception('Charges HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return ChargesResponse.fromJson({'charges': decoded});
      }
      return ChargesResponse.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur parsing charges: $e\nRéponse: ${response.body}');
    }
  }

  static Future<PaymentStatusModel> getPaymentStatus(String reference) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/payment-status')
        .replace(queryParameters: {'reference': reference});
    final response = await ApiClient.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur statut paiement (${response.statusCode}): ${response.body}');
    }
    return PaymentStatusModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<PaymentReceiptModel> getPaymentReceipt(
      String transactionRef) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/coowner/charges/receipt/$transactionRef'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de récupérer le reçu');
    }

    return PaymentReceiptModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ChargePaymentResponse> payCharge({
    required String type,
    required int id,
    required String method,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/$type/$id/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      // Corps identique à Swagger : uniquement "method"
      body: jsonEncode({'method': method}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message'] as String? ?? j['error'] as String? ?? response.body;
      } catch (_) {}
      throw Exception('Erreur paiement (${response.statusCode}) : $detail');
    }

    return ChargePaymentResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ChargeDetailModel> getChargeDetail(String type, int id) async {
    final token = await AuthStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/$type/$id'),
      headers: headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Détail charge HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      return ChargeDetailModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur parsing détail charge: $e\nRéponse: ${response.body}');
    }
  }

  /// Charge l'abonnement actuel du copropriétaire depuis l'API.
  /// Lance une exception si le statut HTTP n'est pas 200.
  static Future<SubscriptionInfo> getSubscription() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coproprietaire/subscription'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SubscriptionInfo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur chargement abonnement (${response.statusCode})');
  }

  /// Initie une souscription Premium via l'API.
  /// [moyenPaiement] : 'WAVE' ou 'ORANGE_MONEY'
  /// [renouvellementAuto] : active le renouvellement automatique
  /// Retourne un [PaymentInitResponse] contenant l'URL de paiement TouchPay.
  static Future<PaymentInitResponse> subscribeToPremium({
    required String moyenPaiement,
    required bool renouvellementAuto,
  }) async {
    final token = await AuthStorage.getToken();
    const successUrl =
        'https://api.solimus.sn/payment-success.html';
    const failedUrl =
        'https://api.solimus.sn/payment-failed.html';

    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/api/coproprietaire/subscription/premium'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'moyenPaiement': moyenPaiement,
        'renouvellementAuto': renouvellementAuto,
        'successUrl': successUrl,
        'failedUrl': failedUrl,
        'successRedirectUrl': successUrl,
        'failedRedirectUrl': failedUrl,
        'redirectSuccessUrl': successUrl,
        'redirectFailedUrl': failedUrl,
      }),
    );

    if (response.statusCode == 200) {
      return PaymentInitResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    String detail = response.body;
    try {
      final j = jsonDecode(response.body) as Map<String, dynamic>;
      detail = j['message'] as String? ??
          j['error'] as String? ??
          j['detail'] as String? ??
          response.body;
    } catch (_) {}
    throw Exception('Erreur souscription (${response.statusCode}) : $detail');
  }

  static Future<ProfileModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? photoPath,
  }) async {
    final token = await AuthStorage.getToken();
    final cleanPhone = phone.trim().replaceAll(' ', '');

    final queryParams = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': cleanPhone,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile').replace(queryParameters: queryParams);

    http.Response response;

    if (photoPath != null) {
      final request = http.MultipartRequest('PUT', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
      }
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phone'] = cleanPhone;
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      response = await ApiClient.sendMultipart(request);
    } else {
      response = await ApiClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 400 && response.statusCode != 401 && response.statusCode != 403) {
        final request = http.MultipartRequest('PUT', uri);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
          request.headers['Accept'] = 'application/json';
        }
        request.fields['firstName'] = firstName;
        request.fields['lastName'] = lastName;
        request.fields['phone'] = cleanPhone;
        response = await ApiClient.sendMultipart(request);
      }
    }


    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = 'Échec de la mise à jour du profil';
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ??
            j['error']?.toString() ??
            j['detail']?.toString() ??
            (j['details'] is List && (j['details'] as List).isNotEmpty
                ? (j['details'] as List).first.toString()
                : response.body);
      } catch (_) {}
      throw Exception(detail);
    }

    return ProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ProfileModel> getProfile() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de récupérer le profil');
    }

    return ProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<String> getDocumentDownloadUrl({
    required String source,
    required int sourceId,
    required String fileName,
  }) async {
    final token = await AuthStorage.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/meetings/$sourceId/documents/download-url')
        .replace(queryParameters: {
      'source': source,
      'sourceId': sourceId.toString(),
      'fileName': fileName,
    });
    dev.log('download-url → source=$source sourceId=$sourceId fileName=$fileName');
    final response = await ApiClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    dev.log('download-url ← ${response.statusCode}: ${response.body}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de générer l\'URL (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['downloadUrl'] as String? ?? '';
  }

  static Future<DocumentsResponse> getDocuments({
    String? search,
    String? category,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile/documents')
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
      throw Exception('Impossible de charger les documents (${response.statusCode}): ${response.body}');
    }

    return DocumentsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<({List<SignalementModel> items, int totalElements})> getSignalements({
    int page = 0,
    int size = 50,
    String? search,
    String? status,
    int? residenceId,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
      if (residenceId != null) 'residenceId': residenceId.toString(),
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile/signalements')
        .replace(queryParameters: queryParams);
    final response = await ApiClient.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les signalements (${response.statusCode}): ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as List? ?? [];
    return (
      items: content.map((e) => SignalementModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalElements: (decoded['totalElements'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<SignalementDetailModel> getSignalementDetail(int id) async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile/signalements/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le signalement (${response.statusCode}): ${response.body}');
    }
    return SignalementDetailModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> createSignalement({
    required String title,
    required String description,
    required int residenceId,
    int? propertyId,
    int? commonFacilityId,
    required String locationType,
    required String urgencyLevel,
    List<String> photos = const [],
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'title': title,
      'description': description,
      'residenceId': residenceId.toString(),
      'locationType': locationType,
      'urgencyLevel': urgencyLevel,
      if (propertyId != null) 'propertyId': propertyId.toString(),
      if (commonFacilityId != null) 'commonFacilityId': commonFacilityId.toString(),
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile/signalements')
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
        detail = j['message']?.toString() ?? j['error']?.toString() ?? j['detail']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création signalement (${response.statusCode}): $detail');
    }
  }

  static Future<bool> getNotificationSettings() async {
    final token = await AuthStorage.getToken();
    final response = await ApiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/api/account/notification-settings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['notificationsEnabled'] as bool? ?? true;
    }
    return true;
  }

  static Future<void> updateNotificationSettings(bool enabled) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/coowner/profile/notifications';
    final response = await ApiClient.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de modifier les notifications (${response.statusCode}): ${response.body}');
    }
  }

  /// Modifie le mot de passe du copropriétaire (PUT /api/coowner/profile/change-password).
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await AuthStorage.getToken();
    final url = '${ApiConfig.baseUrl}/api/coowner/profile/change-password';
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
