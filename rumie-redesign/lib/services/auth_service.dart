import '../api/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<bool> login(String email, String password) async {
    try {
      await _apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    required int age,
    required String gender,
  }) async {
    try {
      await _apiClient.post(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'role': role,
          'age': age,
          'gender': gender,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {}
}
