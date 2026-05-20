import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'di/locator.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/lock_screen.dart';
import 'screens/home_screen.dart';
import 'state/auth_provider.dart';
import 'state/profile_provider.dart';
import 'state/theme_provider.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFAF9F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  Animate.restartOnHotReload = true;

  final authProvider = AuthProvider.deferred();
  setupLocator(onLogout: () => authProvider.logout());
  authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const Rumie(),
    ),
  );
}

class Rumie extends StatefulWidget {
  const Rumie({super.key});

  @override
  State<Rumie> createState() => _RumieState();
}

class _RumieState extends State<Rumie> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AuthProvider>().lock();
    }
  }

  ThemeData _buildTheme(bool dark) {
    AppColors.isDark = dark;
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        brightness: dark ? Brightness.dark : Brightness.light,
        surface: AppColors.surface,
      ).copyWith(
        surface: AppColors.surface,
        primary: AppColors.secondary,
        secondary: AppColors.darkGreen,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          color: AppColors.text,
          decoration: TextDecoration.none,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.text,
          decoration: TextDecoration.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(140)),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.gray,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.secondary : AppColors.border,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.primary,
        thumbColor: AppColors.secondary,
        overlayColor: Color(0x2096E6B3),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: AppColors.text),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBg,
        contentTextStyle: TextStyle(color: AppColors.text),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    // Sync static flag before building theme
    AppColors.isDark = isDark;

    // Update system UI overlay based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rumie',
      theme: _buildTheme(false),
      darkTheme: _buildTheme(true),
      themeMode: themeProvider.mode,
      builder: (context, child) => _LockOverlay(child: child!),
      home: const _AuthGate(),
    );
  }
}

class _LockOverlay extends StatelessWidget {
  final Widget child;
  const _LockOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.status == AuthStatus.authenticated && auth.isLocked) {
      return const LockScreen();
    }
    return child;
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    final Widget screen = switch (status) {
      AuthStatus.unknown => Scaffold(
          backgroundColor: AppColors.background,
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
        ),
      AuthStatus.authenticated    => const HomeScreen(),
      AuthStatus.unauthenticated  => const LandingScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(key: ValueKey(status), child: screen),
    );
  }
}
