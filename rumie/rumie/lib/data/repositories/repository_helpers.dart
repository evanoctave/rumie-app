import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../api/exceptions.dart';

/// Wraps a Dio-backed call so the only exceptions that cross the repo
/// boundary are typed `ApiException` subtypes (V9, V18).
///
/// `ErrorInterceptor` attaches an `ApiException` to `DioException.error` for
/// any HTTP failure; this unwraps that. A transport error without one becomes
/// `NetworkException`. A response that does not match the OpenAPI shape
/// (bad cast / codegen `fromJson` failure) becomes `ServerException` instead
/// of leaking a raw `TypeError`.
Future<T> callApi<T>(Future<T> Function() block) async {
  try {
    return await block();
  } on ApiException {
    rethrow;
  } on DioException catch (e) {
    final attached = e.error;
    if (attached is ApiException) throw attached;
    throw const NetworkException();
  } on TypeError {
    throw const ServerException(_unexpected);
  } on FormatException {
    throw const ServerException(_unexpected);
  } on CheckedFromJsonException {
    throw const ServerException(_unexpected);
  }
}

const _unexpected = 'Received an unexpected response from the server.';
