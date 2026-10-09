import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'dev/demo_locator.dart';
import 'dev/dev_start.dart';
import 'di/locator.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/lock_screen.dart';
import 'screens/home_screen.dart';
import 'state/auth_provider.dart';
import 'state/profile_provider.dart';
import 'state/theme_provider.dart';
import 'theme/app_colors.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';
import 'widgets/ui/wordmark.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Animate.restartOnHotReload = true;

  final authProvider = AuthProvider.deferred();
  if (AuthProvider.demo) {
    setupDemoLocator();
  } else {
    setupLocator(onLogout: () => authProvider.logout());
  }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    // Tokens are static getters gated on this flag; set it before building.
    AppColors.isDark = isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rumie',
      theme: AppTheme.build(false),
      darkTheme: AppTheme.build(true),
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
    final locked = auth.status == AuthStatus.authenticated && auth.isLocked;
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.slow),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
      child: locked ? const LockScreen(key: ValueKey('lock')) : KeyedSubtree(key: const ValueKey('app'), child: child),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    final dev = DevStart.screen();
    if (dev != null && status == AuthStatus.authenticated) return dev;

    final Widget screen = switch (status) {
      AuthStatus.unknown => const _Splash(),
      AuthStatus.authenticated => const HomeScreen(),
      AuthStatus.unauthenticated => const LandingScreen(),
    };

    return AnimatedSwitcher(
      duration: AppMotion.of(context, const Duration(milliseconds: 420)),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.98, end: 1.0).animate(anim), child: child),
      ),
      child: KeyedSubtree(key: ValueKey(status), child: screen),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: const Wordmark(size: 40)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.55, end: 1, duration: 900.ms, curve: Curves.easeInOut),
      ),
    );
  }
}
