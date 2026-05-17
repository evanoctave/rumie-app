import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  static String? _token;

  final String? authToken;

  ApiClient({this.authToken});

  static Future<void> setToken(String token) async {
    _token = token;
  }

  static Future<void> clearToken() async {
    _token = null;
  }

  Uri _uri(String path) {
    return Uri.parse('${ApiEndpoints.baseUrl}$path');
  }

  Map<String, String> _headers() {
    final tokenToUse = authToken ?? _token;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (tokenToUse != null && tokenToUse.isNotEmpty)
        'Authorization': 'Bearer $tokenToUse',
    };
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      _uri(path),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      _uri(path),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic body;

    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    throw ApiException(
      statusCode: statusCode,
      message: body is Map && body['detail'] != null
          ? body['detail'].toString()
          : body?.toString() ?? 'Request failed',
    );
  }
}
