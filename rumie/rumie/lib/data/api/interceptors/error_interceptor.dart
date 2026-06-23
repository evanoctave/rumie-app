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

  @visibleForTesting
  static ApiException mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(err.message ?? 'Network error');
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        if (status == 422) {
          return ValidationException(parseFieldErrors(err.response?.data));
        }
        if (status == 401) {
          return const UnauthorizedException();
        }
        if (status >= 500) {
          return ServerException(
            'Server error ($status)',
            statusCode: status,
          );
        }
        return ServerException(
          'Request failed ($status)',
          statusCode: status,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkException(err.message ?? 'Network error');
    }
  }

  /// Parses FastAPI `HTTPValidationError` shape into a field-keyed message map.
  /// Field key = last element of `loc` (skipping `'body'`/`'query'`/`'path'`
  /// scope prefixes). Items without a usable key bucket under `_`.
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

  static String _fieldFrom(dynamic loc) {
    if (loc is! List || loc.isEmpty) return '_';
    final filtered = loc.where((e) => e != 'body' && e != 'query' && e != 'path');
    final last = filtered.isEmpty ? loc.last : filtered.last;
    return last.toString();
  }
}
