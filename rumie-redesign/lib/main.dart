import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'di/locator.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'state/auth_provider.dart';
import 'state/profile_provider.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  Animate.restartOnHotReload = true;

  final authProvider = AuthProvider();
  setupLocator(onLogout: () => authProvider.logout());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const Rumie(),
    ),
  );
}

class Rumie extends StatelessWidget {
  const Rumie({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.dmSansTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rumie',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.green,
          surface: AppColors.surface,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.green,
          surface: AppColors.surface,
          onSurface: AppColors.text,
        ),
        textTheme: base.copyWith(
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 16,
            color: AppColors.text,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: AppColors.gray),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.gray,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withAlpha(30),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: AppColors.text),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.text,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.text,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
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
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
