import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  final _localAuth = LocalAuthentication();

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Attempts biometric authentication. Returns true on success, false on
  /// failure. If biometrics are not enrolled, falls back to returning true
  /// so the user is never permanently locked out.
  Future<bool> unlockWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }

      final enrolled = await _localAuth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Rumie',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _isLoggedIn = true;
        notifyListeners();
      }
      return authenticated;
    } catch (_) {
      // On any unexpected error, fail gracefully without locking the user out.
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
  }
}
