import 'dart:io' show Directory, File, Platform;

import 'package:flutter/material.dart';

import '../domain/entities/entities.dart';
import '../screens/auth/landing_screen.dart';
import '../screens/auth/lock_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_create_screen.dart';
import '../screens/profile_view_screen.dart';
import '../screens/settings_screen.dart';
import 'demo_data.dart';

/// Design-iteration launcher. Example:
///
///   flutter run --dart-define=RUMIE_DEMO=true --dart-define=RUMIE_START=chat
///
/// Opens straight into one screen with sample data. Unset in normal builds.
/// Only honoured when the app is authenticated (demo flag or real login).
class DevStart {
  DevStart._();

  static const String _defined = String.fromEnvironment('RUMIE_START');

  /// Compile-time define wins; otherwise a process env var; otherwise the
  /// first line of `tmp/dev_start.txt` in the app container (which
  /// `xcrun simctl get_app_container … data` locates), so a screenshot
  /// script can pick a screen without rebuilding.
  static String get target {
    if (_defined.isNotEmpty) return _defined;
    final env = Platform.environment['RUMIE_START'];
    if (env != null && env.isNotEmpty) return env;
    return _fileLines().firstOrNull ?? '';
  }

  /// `RUMIE_DARK=1`, or a second line `dark` in the file, starts dark.
  static bool get dark {
    if (const bool.fromEnvironment('RUMIE_DARK')) return true;
    if (Platform.environment['RUMIE_DARK'] == '1') return true;
    return _fileLines().elementAtOrNull(1)?.trim() == 'dark';
  }

  static List<String>? _cachedLines;

  static List<String> _fileLines() {
    if (_cachedLines != null) return _cachedLines!;
    try {
      // NSTemporaryDirectory() lives inside the app container on iOS.
      final file = File('${Directory.systemTemp.path}/dev_start.txt');
      if (!file.existsSync()) return _cachedLines = const [];
      return _cachedLines = file.readAsLinesSync().map((l) => l.trim()).toList();
    } catch (_) {
      return _cachedLines = const [];
    }
  }

  static Widget? screen() {
    if (target.isEmpty) return null;
    return switch (target) {
      'discover' => const HomeScreen(),
      'matches' => const HomeScreen(initialIndex: 1),
      'listings' => const HomeScreen(initialIndex: 2),
      'profile' => const HomeScreen(initialIndex: 3),
      'profile-view' => ProfileViewScreen(candidate: DemoData.candidates[1]),
      'chat' => ChatScreen(match: DemoData.matches.first),
      'settings' => const SettingsScreen(),
      'create' => ProfileCreateScreen(onSave: (_) async {}),
      'landing' => const LandingScreen(),
      'login' => const LoginScreen(),
      'signup' => const SignupScreen(role: Role.rumie),
      'lock' => const LockScreen(),
      _ => null,
    };
  }
}
