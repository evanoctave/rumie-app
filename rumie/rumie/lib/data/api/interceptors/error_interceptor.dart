import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      return handler.next(err);
    }
    final mapped = mapException(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: mapped,
      message: mapped.message,
      stackTrace: err.stackTrace,
    ));
  }

  /// Maps a transport/HTTP failure to a typed [ApiException] whose message is
  /// user-safe (V6). The raw `DioException.message` is deliberately dropped:
  /// it carries developer-facing text ("This exception was thrown because…").
  @visibleForTesting
  static ApiException mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'The connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        if (status == 422) {
          return ValidationException(parseFieldErrors(data));
        }
        if (status == 401) {
          return const UnauthorizedException();
        }
        if (status >= 500) {
          return ServerException(
            'Something went wrong on our end. Please try again shortly.',
            statusCode: status,
          );
        }
        return ServerException(
          _messageForStatus(status),
          statusCode: status,
          detail: parseDetail(data),
        );
      case DioExceptionType.cancel:
        return const NetworkException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkException(
          "Couldn't establish a secure connection.",
        );
      case DioExceptionType.unknown:
        return const NetworkException();
    }
  }

  static String _messageForStatus(int status) {
    switch (status) {
      case 400:
        return "That request couldn't be completed.";
      case 403:
        return "You don't have access to that.";
      case 404:
        return "We couldn't find what you were looking for.";
      case 409:
        return 'That conflicts with something that already exists.';
      case 429:
        return 'Too many requests. Please slow down and try again.';
      default:
        return 'Request failed. Please try again.';
    }
  }

  /// FastAPI `HTTPException` bodies are `{"detail": "<string>"}`.
  static String? parseDetail(dynamic data) {
    if (data is Map && data['detail'] is String) {
      final d = (data['detail'] as String).trim();
      if (d.isNotEmpty && d.length <= 200) return d;
    }
    return null;
  }

  /// Parses FastAPI `HTTPValidationError` shape into a field-keyed message map.
  /// Field key = last *named* element of `loc` after dropping the leading
  /// scope (`body`/`query`/`path`/`header`/`cookie`) and skipping list indices,
  /// so `['body','preferences','tags',0]` → `tags` and `['body','body']` →
  /// `body` (MessageIn's field). Items without a usable key (e.g.
  /// `loc: ['body']`) bucket under `_`.
  static Map<String, List<String>> parseFieldErrors(dynamic data) {
    if (data is! Map) return const {};
    final detail = data['detail'];
    if (detail is! List) return const {};
    final out = <String, List<String>>{};
    for (final item in detail) {
      if (item is! Map) continue;
      final msg = item['msg'];
      final loc = item['loc'];
      if (msg is! String) continue;
      final field = _fieldFrom(loc);
      out.putIfAbsent(field, () => <String>[]).add(msg);
    }
    return out;
  }

  static const _locScopes = {'body', 'query', 'path', 'header', 'cookie'};

  static String _fieldFrom(dynamic loc) {
    if (loc is! List || loc.isEmpty) return '_';
    final rest = _locScopes.contains(loc.first) ? loc.skip(1) : loc;
    final named = rest.whereType<String>();
    return named.isEmpty ? '_' : named.last;
  }
}
