// lib/services/api_client.dart
import 'package:http/http.dart' as http;
import 'app_navigator.dart';

/// Client HTTP centralisé avec interception automatique des erreurs de session (401 / 403).
class ApiClient {
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await http.get(url, headers: headers);
    AppNavigator.checkResponse(response);
    return response;
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.post(url, headers: headers, body: body);
    AppNavigator.checkResponse(response);
    return response;
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.put(url, headers: headers, body: body);
    AppNavigator.checkResponse(response);
    return response;
  }

  static Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.patch(url, headers: headers, body: body);
    AppNavigator.checkResponse(response);
    return response;
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.delete(url, headers: headers, body: body);
    AppNavigator.checkResponse(response);
    return response;
  }

  static Future<http.Response> sendMultipart(http.MultipartRequest request) async {
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    AppNavigator.checkResponse(response);
    return response;
  }
}
