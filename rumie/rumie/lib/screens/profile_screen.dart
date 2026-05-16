import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/pref_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pink, AppColors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 56))),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'You, 23',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            const PrefRow(emoji: '💰', label: 'Budget', value: '\$1,000–1,500/mo'),
            const PrefRow(emoji: '📍', label: 'Location', value: 'SF Bay Area'),
            const PrefRow(emoji: '🛌', label: 'Move-in', value: 'Within 1 month'),
            const PrefRow(emoji: '🧹', label: 'Tidiness', value: 'Tidy'),
            const PrefRow(emoji: '🐱', label: 'Pets', value: 'Cat-friendly'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
