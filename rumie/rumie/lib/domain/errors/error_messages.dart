import 'api_exception.dart';

/// User-safe text for any error caught in the UI (V6). Typed repository
/// errors already carry a safe message; anything else gets [fallback].
String userMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) =>
    error is ApiException ? error.message : fallback;

/// Field → messages for a 422 (V5); empty for every other error.
Map<String, List<String>> fieldErrorsOf(Object error) =>
    error is ValidationException ? error.fieldErrors : const {};

/// First server message for [field], or null.
String? firstFieldError(Map<String, List<String>> errors, String field) {
  final list = errors[field];
  return (list == null || list.isEmpty) ? null : list.first;
}
