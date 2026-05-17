import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/rumie_api.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService storage = StorageService();

  String? token;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> load() async {
    token = await storage.getAccessToken();

    if (token != null && token!.isNotEmpty) {
      await ApiClient.setToken(token!);
    }

    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final api = RumieApi(
      apiClient: ApiClient(),
    );

    final response = await api.login(
      email: email,
      password: password,
    ) as Map<String, dynamic>;

    final accessToken = response['access_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(
        'Login failed: missing access token',
      );
    }

    token = accessToken;

    await storage.saveAccessToken(token!);

    await ApiClient.setToken(token!);

    notifyListeners();
  }

  Future<void> logout() async {
    token = null;

    await storage.clear();

    await ApiClient.clearToken();

    notifyListeners();
  }
}
