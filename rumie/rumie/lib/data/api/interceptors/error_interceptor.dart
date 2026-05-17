import 'package:dio/dio.dart';

/// Stub: passes errors through unchanged.
/// Full impl (422 → ValidationException, 5xx → ServerException, timeout → NetworkException)
/// lands in T6 (M2).
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
