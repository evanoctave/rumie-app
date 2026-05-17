import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/pref_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildAvatarSection(),
            const SizedBox(height: 28),
            _buildStatsRow(),
            const SizedBox(height: 28),
            _buildPreferences(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.teal, AppColors.blue],
      ).createShader(bounds),
      child: const Text(
        'Your Profile',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _avatarController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: SweepGradient(
                    startAngle: _avatarController.value * 6.28,
                    endAngle: _avatarController.value * 6.28 + 6.28,
                    colors: const [
                      AppColors.teal,
                      AppColors.blue,
                      AppColors.green,
                      AppColors.orange,
                      AppColors.teal,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withAlpha(100),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: SvgPicture.asset('assets/icons/av_you.svg', fit: BoxFit.cover),
                  ),
                ),
              );
            },
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 14),
          const Text(
            'You, 23',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_location.svg',
                width: 13,
                height: 13,
                colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
              ),
              const SizedBox(width: 3),
              const Text(
                'SF Bay Area',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('12', 'Swipes', AppColors.blue),
        const SizedBox(width: 12),
        _statCard('3', 'Matches', AppColors.green),
        const SizedBox(width: 12),
        _statCard('1', 'Chats', AppColors.teal),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.blue.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_edit.svg',
                      width: 13,
                      height: 13,
                      colorFilter: const ColorFilter.mode(AppColors.blue, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const PrefRow(emoji: '💰', label: 'Budget', value: '\$1,000–1,500/mo'),
        const PrefRow(emoji: '📍', label: 'Location', value: 'SF Bay Area'),
        const PrefRow(emoji: '🛌', label: 'Move-in', value: 'Within 1 month'),
        const PrefRow(emoji: '🧹', label: 'Tidiness', value: 'Tidy'),
        const PrefRow(emoji: '🐱', label: 'Pets', value: 'Cat-friendly'),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _gradientButton(
          label: 'Edit Profile',
          svgAsset: 'assets/icons/ic_edit.svg',
          colors: [AppColors.blue, AppColors.teal],
          onTap: () {},
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_settings.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _gradientButton({
    required String label,
    required String svgAsset,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
