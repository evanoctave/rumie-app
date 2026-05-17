class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return 'ApiException: $message';
    }
    return 'ApiException($statusCode): $message';
  }
}

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    throw const ApiException('API client is not connected yet.');
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    throw const ApiException('API client is not connected yet.');
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    throw const ApiException('API client is not connected yet.');
  }

  Future<void> delete(String path) async {
    throw const ApiException('API client is not connected yet.');
  }
}
