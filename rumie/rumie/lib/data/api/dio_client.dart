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

  static String get baseUrl => '$baseUrlEnv/api/v1';

  /// Bare Dio used by [AuthInterceptor] to call `/auth/refresh` without
  /// recursing through itself. Carries logging only.
  static Dio createRefreshDio() {
    final dio = _base();
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  }

  /// Bare Dio used by `AssetRepositoryImpl` to PUT bytes to a presigned URL.
  /// No baseUrl, no auth, no error mapping — V8 forbids `Authorization` on
  /// the S3 PUT, and the URL is absolute.
  static Dio createUploadPutDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(LoggingInterceptor());
    return dio;
  }

  static Dio create({
    required TokenStore tokenStore,
    required Dio refreshDio,
    required Dio Function() mainDio,
    void Function()? onLogout,
  }) {
    final dio = _base();
    dio.interceptors.addAll([
      AuthInterceptor(
        tokenStore: tokenStore,
        refreshDio: refreshDio,
        mainDio: mainDio,
        onLogout: onLogout,
      ),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
    return dio;
  }

  static Dio _base() => Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ));
}
