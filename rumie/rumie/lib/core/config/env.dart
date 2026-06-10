/// Centralized environment configuration for Rumie.
///
/// All domain/host knowledge lives here so nothing else in the app hardcodes
/// URLs. Override at build time with:
///
/// ```bash
/// flutter run --dart-define=RUMIE_BASE_URL=https://rumie.xyz
/// flutter run --dart-define=RUMIE_BASE_URL=http://localhost:8000
/// ```
class Env {
  Env._();

  /// Production app/API domain. `rumie.tech` is reserved for the dev /
  /// landing / docs site and is intentionally not referenced by the app.
  static const String baseUrl = String.fromEnvironment(
    'RUMIE_BASE_URL',
    defaultValue: 'https://rumie.xyz',
  );

  /// Versioned API prefix appended to [baseUrl] by the HTTP client.
  static const String apiPrefix = '/api/v1';

  /// Full API base used by the Dio client.
  static String get apiBaseUrl => '$baseUrl$apiPrefix';
}
