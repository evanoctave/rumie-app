import 'package:dio/dio.dart';

import '../api/exceptions.dart';

/// Wraps a Dio-backed call so the only exceptions that cross the repo
/// boundary are typed `ApiException` subtypes (V9).
///
/// `ErrorInterceptor` attaches an `ApiException` to `DioException.error` for
/// any HTTP failure; this unwraps that. Anything else becomes
/// `NetworkException` (transport / unknown).
Future<T> callApi<T>(Future<T> Function() block) async {
  try {
    return await block();
  } on DioException catch (e) {
    final attached = e.error;
    if (attached is ApiException) throw attached;
    throw NetworkException(e.message ?? 'Network error');
  }
}
