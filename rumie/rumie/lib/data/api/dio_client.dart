import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'token_store.dart';

class DioClient {
  static const baseUrlEnv = String.fromEnvironment(
    'RUMIE_BASE_URL',
    defaultValue: 'https://rumie.xyz',
  );

  static Dio create(TokenStore tokenStore) {
    final dio = Dio(BaseOptions(
      baseUrl: '$baseUrlEnv/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {'Content-Type': 'application/json'},
    ));
    dio.interceptors.addAll([
      AuthInterceptor(tokenStore),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
    return dio;
  }
}
