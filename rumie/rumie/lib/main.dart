import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'di/locator.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/home_screen.dart';
import 'state/auth_provider.dart';
import 'theme/app_colors.dart';

AuthProvider? _authProviderRef;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );
  Animate.restartOnHotReload = true;

  setupLocator(
    onLogout: () => _authProviderRef?.logout(),
  );

  final authProvider = AuthProvider();
  _authProviderRef = authProvider;

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const Rumie(),
    ),
  );
}

class Rumie extends StatelessWidget {
  const Rumie({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rumie',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ).copyWith(
          surface: AppColors.surface,
          primary: AppColors.primary,
          secondary: AppColors.teal,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.text),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.text),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.gray),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.gray,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border,
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.primary,
          overlayColor: Color(0x201A8CFF),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: AppColors.text),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.cardBg,
          contentTextStyle: TextStyle(color: AppColors.text),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LandingScreen();
    }
  }
}
