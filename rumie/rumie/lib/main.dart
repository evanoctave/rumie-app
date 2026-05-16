import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const RoomieApp());

class RoomieApp extends StatelessWidget {
  const RoomieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          primary: AppColors.purple,
          secondary: AppColors.pink,
        ),
        scaffoldBackgroundColor: AppColors.background,
        // To use a custom font, uncomment the line below after declaring
        // the font in pubspec.yaml and dropping the .ttf into assets/fonts/.
        // fontFamily: 'Nunito',
      ),
      home: const HomeScreen(),
    );
  }
}
