import 'dart:async';

import 'package:dio/dio.dart';

import '../exceptions.dart';
import '../token_store.dart';

class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;
  final Dio refreshDio;
  final Dio Function() mainDio;
  final void Function()? onLogout;

  Future<bool>? _pendingRefresh;

  AuthInterceptor({
    required this.tokenStore,
    required this.refreshDio,
    required this.mainDio,
    this.onLogout,
  });

  static const skipPaths = {
    '/api/v1/auth/login',
    '/api/v1/auth/register',
    '/api/v1/auth/refresh',
    '/api/v1/health',
  };

  bool _isSkipped(RequestOptions opts) =>
      skipPaths.contains(opts.path) || skipPaths.contains(opts.uri.path);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isSkipped(options)) return handler.next(options);
    final token = await tokenStore.readAccess();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// `RequestOptions.extra` flag set on the single retry after a refresh, so
  /// a second 401 on the retried request is surfaced instead of looping
  /// refresh → retry → 401 forever.
  static const retriedKey = 'rumie_auth_retried';

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final opts = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _isSkipped(opts) ||
        opts.extra[retriedKey] == true) {
      return handler.next(err);
    }

    // If another request already refreshed while this one was in flight, the
    // stored token differs from the one this request carried — just retry with
    // the new token instead of burning the (rotated) refresh token again (V3).
    final sentAuth = opts.headers['Authorization'];
    final current = await tokenStore.readAccess();
    final alreadyRefreshed =
        current != null && sentAuth != null && sentAuth != 'Bearer $current';

    final refreshed = alreadyRefreshed || await _refreshOnce();
    if (!refreshed) {
      await tokenStore.clear();
      onLogout?.call();
      return handler.reject(DioException(
        requestOptions: opts,
        response: err.response,
        type: DioExceptionType.badResponse,
        error: const UnauthorizedException(),
        message: 'Session expired',
      ));
    }

    final newToken = await tokenStore.readAccess();
    final retryOpts = opts.copyWith(
      extra: {...opts.extra, retriedKey: true},
    );
    if (newToken != null) {
      retryOpts.headers['Authorization'] = 'Bearer $newToken';
    }
    try {
      final response = await mainDio().fetch<dynamic>(retryOpts);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  Future<bool> _refreshOnce() {
    final pending = _pendingRefresh;
    if (pending != null) return pending;

    final completer = Completer<bool>();
    _pendingRefresh = completer.future;

    () async {
      try {
        final refresh = await tokenStore.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          completer.complete(false);
          return;
        }
        final resp = await refreshDio.post<dynamic>(
          '/auth/refresh',
          data: {'refresh': refresh},
        );
        final data = resp.data;
        if (resp.statusCode == 200 && data is Map) {
          final access = data['access'];
          final newRefresh = data['refresh'];
          if (access is String && newRefresh is String) {
            await tokenStore.write(access: access, refresh: newRefresh);
            completer.complete(true);
            return;
          }
        }
        completer.complete(false);
      } catch (_) {
        completer.complete(false);
      } finally {
        _pendingRefresh = null;
      }
    }();

    return completer.future;
  }
}
