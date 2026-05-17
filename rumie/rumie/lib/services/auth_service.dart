import '../api/api_client.dart';
import '../api/rumie_api.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService storage;

  AuthService(this.storage);

  Future<RumieApi> authorizedApi() async {
    final token = await storage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      await ApiClient.setToken(token);
    }

    return RumieApi(
      apiClient: ApiClient(),
    );
  }
}
