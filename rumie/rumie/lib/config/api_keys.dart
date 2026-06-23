// Add real keys via --dart-define at build time:
// flutter run --dart-define=RENTCAST_KEY=xxx --dart-define=WALKSCORE_KEY=xxx
class ApiKeys {
  static const String rentcast  = String.fromEnvironment('RENTCAST_KEY',  defaultValue: '');
  static const String walkScore = String.fromEnvironment('WALKSCORE_KEY', defaultValue: '');
}
