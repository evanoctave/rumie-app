/// Typed failures thrown by every repository (V9, V18).
///
/// [message] is always user-safe (V6): it never carries raw Dio/transport
/// text, so screens may show it directly.
sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Your session has expired. Please sign in again.']);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;
  const ValidationException(this.fieldErrors,
      [super.message = 'Please check the highlighted fields.']);
}

class ServerException extends ApiException {
  final int? statusCode;

  /// FastAPI `detail` string when the server sent one (4xx). Server-authored,
  /// intended for clients; kept separate from [message].
  final String? detail;

  const ServerException(super.message, {this.statusCode, this.detail});
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No connection. Check your internet and try again.']);
}

/// Tokens could not be persisted to secure storage (V14). The auth call is
/// treated as failed.
class StorageException extends ApiException {
  const StorageException([super.message = "Couldn't save your session on this device."]);
}
