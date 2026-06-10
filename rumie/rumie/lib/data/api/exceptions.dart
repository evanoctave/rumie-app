sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;
  const ValidationException(
    this.fieldErrors, [
    super.message = 'Validation failed',
  ]);
}

class ServerException extends ApiException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error']);
}
