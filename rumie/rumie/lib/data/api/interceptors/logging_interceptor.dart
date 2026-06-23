import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  static const redactedMarker = '[REDACTED]';
  static const sensitiveBodyFields = {'password', 'refresh', 'access'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '→ ${options.method} ${options.uri}\n'
        '  headers: ${redactHeaders(options.headers)}\n'
        '  body: ${redactBody(options.data)}',
        name: 'rumie.http',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '← ${response.statusCode} ${response.requestOptions.uri}\n'
        '  body: ${redactBody(response.data)}',
        name: 'rumie.http',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
        '  ${err.type}: ${err.message}',
        name: 'rumie.http',
      );
    }
    handler.next(err);
  }

  @visibleForTesting
  static Map<String, dynamic> redactHeaders(Map<String, dynamic> headers) {
    final out = Map<String, dynamic>.from(headers);
    for (final key in out.keys.toList()) {
      if (key.toLowerCase() == 'authorization') out[key] = redactedMarker;
    }
    return out;
  }

  @visibleForTesting
  static dynamic redactBody(dynamic data) {
    if (data is Map) {
      return data.map((k, v) {
        if (sensitiveBodyFields.contains(k)) return MapEntry(k, redactedMarker);
        return MapEntry(k, redactBody(v));
      });
    }
    if (data is List) return data.map(redactBody).toList();
    return data;
  }
}
