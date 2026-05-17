import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

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
  runApp(const Rumie());
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
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ).copyWith(
          surface: AppColors.surface,
          primary: AppColors.blue,
          secondary: AppColors.teal,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'serif',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'serif',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
