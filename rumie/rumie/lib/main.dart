import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
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
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'serif',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'serif',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
