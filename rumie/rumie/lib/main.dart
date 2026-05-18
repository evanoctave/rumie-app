import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'di/locator.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/lock_screen.dart';
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
      systemNavigationBarColor: AppColors.background,
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
      ],
      child: const Rumie(),
    ),
  );
}

// Stateful so it can observe the app lifecycle and lock on background.
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rumie',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          brightness: Brightness.light,
          surface: AppColors.surface,
        ).copyWith(
          surface: AppColors.surface,
          primary: AppColors.secondary,
          secondary: AppColors.darkGreen,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.text,
            decoration: TextDecoration.none,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.text,
            decoration: TextDecoration.none,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(140)),
          filled: true,
          fillColor: AppColors.surface,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
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
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.secondary,
          overlayColor: Color(0x2096E6B3),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: AppColors.text),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.cardBg,
          contentTextStyle: TextStyle(color: AppColors.text),
        ),
        appBarTheme: const AppBarTheme(
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
      ),
      // builder wraps every route — lock screen always appears on top,
      // even over modals or pushed pages like ChatScreen.
      builder: (context, child) => _LockOverlay(child: child!),
      home: const _AuthGate(),
    );
  }
}

/// Sits above the entire navigator. When the user is authenticated but locked,
/// replaces everything with the lock screen so no app content leaks through.
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
      AuthStatus.unknown => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
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
