import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/api_exception.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  /// `flutter run --dart-define=RUMIE_DEMO=true` runs against in-memory
  /// repositories (see `lib/dev/demo_locator.dart`). The only behaviour
  /// change here is skipping the Face ID lock on launch.
  static const bool demo = bool.fromEnvironment('RUMIE_DEMO');

  AuthStatus _status = AuthStatus.unknown;
  UserOut? _user;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};
  bool _loading = false;
  bool _isLocked = false;

  AuthStatus get status => _status;
  UserOut? get user => _user;
  String? get error => _error;

  /// Per-field server messages from the last failed login/register (422, V5).
  Map<String, List<String>> get fieldErrors => _fieldErrors;
  bool get loading => _loading;
  bool get isLocked => _isLocked;

  /// Normal constructor: starts token check immediately.
  AuthProvider() {
    _checkToken();
  }

  /// Used by main() so setupLocator() can be called between construction and
  /// the first async token check, ensuring onLogout has a valid reference.
  AuthProvider.deferred();

  /// Called by main() after setupLocator() to kick off the token check.
  void initialize() => _checkToken();

  Future<void> _checkToken() async {
    final hasSession = await locator<AuthRepository>().hasSession();
    if (!hasSession) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user = await locator<AuthRepository>().me();
      _status = AuthStatus.authenticated;
      _isLocked = !demo; // require Face ID on every cold launch
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    _fieldErrors = const {};
    notifyListeners();
    try {
      await locator<AuthRepository>().login(LoginIn(email: email, password: password));
      _user = await locator<AuthRepository>().me();
      _status = AuthStatus.authenticated;
      _isLocked = false; // just logged in, no need to re-lock immediately
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _fieldErrors = fieldErrorsOf(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegisterIn body) async {
    _loading = true;
    _error = null;
    _fieldErrors = const {};
    notifyListeners();
    try {
      final out = await locator<AuthRepository>().register(body);
      _user = out.user;
      _status = AuthStatus.authenticated;
      _isLocked = false; // just registered, no need to lock
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _fieldErrors = fieldErrorsOf(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Called when the app goes to the background.
  void lock() {
    if (_status == AuthStatus.authenticated && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Triggers the system Face ID / biometric prompt and unlocks on success.
  /// Falls back to passcode when Face ID is unavailable, and unlocks silently
  /// on devices that have no authentication configured at all (e.g. simulator).
  Future<bool> unlockWithBiometrics() async {
    final localAuth = LocalAuthentication();
    try {
      final isSupported = await localAuth.isDeviceSupported();
      if (!isSupported) {
        // No auth hardware at all — unlock silently.
        _unlock();
        return true;
      }

      final canCheck = await localAuth.canCheckBiometrics;
      if (!canCheck) {
        // Hardware present but no biometrics enrolled (also covers simulator
        // without Face ID configured). Unlock silently rather than blocking.
        _unlock();
        return true;
      }

      final ok = await localAuth.authenticate(
        localizedReason: 'Unlock Rumie',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device passcode as fallback
          stickyAuth: true,     // keep prompt alive if user briefly switches apps
        ),
      );
      if (ok) _unlock();
      return ok;
    } catch (_) {
      // PlatformException (e.g. LAErrorPasscodeNotSet, lockout) — unlock
      // silently so the user is never permanently blocked.
      _unlock();
      return true;
    }
  }

  void _unlock() {
    _isLocked = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await locator<AuthRepository>().logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _isLocked = false;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    if (e is UnauthorizedException) return 'Incorrect email or password.';
    if (e is ServerException && e.statusCode == 409) {
      return 'An account with that email already exists.';
    }
    if (e is ServerException && e.statusCode == 400 && e.detail != null) {
      return e.detail!;
    }
    return userMessage(e);
  }
}
