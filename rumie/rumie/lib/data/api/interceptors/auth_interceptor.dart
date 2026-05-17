import 'package:dio/dio.dart';

import '../token_store.dart';

/// Stub: attaches bearer if token present and path not in skip set.
/// Full impl (401 → refresh → retry, single-flight) lands in T5 (M2).
class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;

  AuthInterceptor(this.tokenStore);

  static const skipPaths = {
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/api/v1/auth/refresh',
    '/api/v1/health',
  };

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (skipPaths.contains(options.path)) {
      return handler.next(options);
    }
    final token = await tokenStore.readAccess();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
