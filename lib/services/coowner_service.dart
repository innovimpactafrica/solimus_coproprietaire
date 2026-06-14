import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
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
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$interventionId/payer-acompte'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
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

  static Future<List<ResidenceModel>> getInterventionResidences() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/residences'),
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

  static Future<List<PropertyModel>> getInterventionProperties(int residenceId) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/residences/$residenceId/properties'),
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
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/specialties'),
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
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/residences/$residenceId/common-facilities'),
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

    final response = await http.get(
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

  static Future<ChargePaymentResponse> validerSolde({
    required int interventionId,
    required String methode,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$interventionId/valider-solde'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
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

  static Future<List<QuoteModel>> getQuotes(int interventionId) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$interventionId/quotes'),
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
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$interventionId/quotes/$quoteId'),
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
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$interventionId/accept-quote/$quoteId'),
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

  static Future<InterventionDetailModel> createIntervention({
    required String title,
    required String description,
    required int residenceId,
    int? propertyId,
    int? commonFacilityId,
    required int specialtyId,
    required String locationType,
    String? managementMode,
    required String urgencyLevel,
    List<String> photos = const [],
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'title': title,
      'description': description,
      'residenceId': residenceId.toString(),
      'specialtyId': specialtyId.toString(),
      'locationType': locationType,
      'urgencyLevel': urgencyLevel,
      if (propertyId != null) 'propertyId': propertyId.toString(),
      if (commonFacilityId != null) 'commonFacilityId': commonFacilityId.toString(),
      if (managementMode != null) 'managementMode': managementMode,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions')
        .replace(queryParameters: queryParams);

    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    for (final photoPath in photos) {
      request.files.add(await http.MultipartFile.fromPath('photos', photoPath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      try {
        final j = jsonDecode(response.body) as Map<String, dynamic>;
        detail = j['message']?.toString() ?? j['error']?.toString() ?? j['detail']?.toString() ?? response.body;
      } catch (_) {}
      throw Exception('Erreur création intervention (${response.statusCode}): $detail');
    }

    return InterventionDetailModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<InterventionDetailModel> getInterventionDetail(int id) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions/$id'),
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
    int size = 20,
    String? status,
    String? search,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/owner/interventions')
        .replace(queryParameters: queryParams);
    final response = await http.get(
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

  static Future<DashboardModel> getDashboard() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le dashboard');
    }

    return DashboardModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<ResidenceModel>> getResidences() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/residences'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les résidences');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ResidenceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<PropertyModel>> getProperties(int residenceId) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/coowner/residences/$residenceId/properties'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les appartements');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<MeetingDetailModel> getMeetingDetail(int meetingId) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/meetings/$meetingId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le détail de la réunion');
    }

    return MeetingDetailModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<int> getUpcomingMeetingsCount() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
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
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/meetings/calendar')
        .replace(queryParameters: {
      'year': year.toString(),
      'month': month.toString(),
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger le calendrier (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as List? ?? [];
    final result = <String, List<MeetingModel>>{};
    for (final item in content) {
      final date = item['date'] as String;
      final meetings = (item['meetings'] as List? ?? [])
          .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      // Normaliser la clé en ISO "YYYY-MM-DD"
      String isoDate = date;
      if (date.contains('/')) {
        final parts = date.split('/');
        if (parts.length == 3) {
          isoDate = '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
        }
      }
      result[isoDate] = meetings;
    }
    return result;
  }

  static Future<List<MeetingModel>> getMeetings() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/meetings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les réunions');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List ? decoded : (decoded['content'] as List? ?? decoded['meetings'] as List? ?? []);
    return list
        .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ChargesResponse> getCharges({
    int page = 0,
    int size = 20,
    String? status,
    String? search,
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges')
        .replace(queryParameters: queryParams);

    final response = await http.get(
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

  static Future<PaymentReceiptModel> getPaymentReceipt(
      String transactionRef) async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/api/coowner/charges/payment/$transactionRef/receipt'),
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
    required int allocationId,
    required String method,
  }) async {
    final token = await AuthStorage.getToken();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/$allocationId/pay'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
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

  static Future<ChargeDetailModel> getChargeDetail(int id) async {
    final token = await AuthStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/coowner/charges/$id'),
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

  static Future<SubscriptionInfo> getSubscription() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
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

  static Future<PaymentInitResponse> subscribeToPremium({
    required String moyenPaiement,
    required bool renouvellementAuto,
  }) async {
    final token = await AuthStorage.getToken();
    const successUrl =
        'https://api.solimus.innovimpactdev.cloud/payment-success.html';
    const failedUrl =
        'https://api.solimus.innovimpactdev.cloud/payment-failed.html';

    final response = await http.post(
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

    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/coowner/profile').replace(
      queryParameters: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
    );

    final request = http.MultipartRequest('PUT', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (photoPath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('photo', photoPath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Échec de la mise à jour du profil');
    }

    return ProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<ProfileModel> getProfile() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
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

  static Future<DocumentsResponse> getDocuments({
    String? search,
    String? documentType,
    String? source,
    int page = 0,
    int size = 20,
    String sort = 'date,desc',
  }) async {
    final token = await AuthStorage.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sort': sort,
      if (search != null && search.isNotEmpty) 'search': search,
      if (documentType != null) 'documentType': documentType,
      if (source != null) 'source': source,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/coowner/documents')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Impossible de charger les documents');
    }

    return DocumentsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<bool> getNotificationSettings() async {
    final token = await AuthStorage.getToken();
    final response = await http.get(
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
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/account/notification-settings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'notificationsEnabled': enabled}),
    );
  }
}
