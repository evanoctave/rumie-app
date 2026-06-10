import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/rumie_card.dart';
import '../widgets/section_header.dart';
import 'safety_center_screen.dart';

/// Settings hub: account, privacy, verification, help, logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Settings',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.lg,
          Spacing.gutter,
          40,
        ),
        children: [
          const SectionHeader(title: 'Account'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _row(
                  context,
                  Icons.person_rounded,
                  'Account details',
                  onTap: () => _comingSoon(context),
                ),
                _divider(),
                _row(
                  context,
                  Icons.verified_rounded,
                  'Student verification',
                  trailingLabel: 'Verified',
                  trailingColor: AppColors.green,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SafetyCenterScreen(),
                        ),
                      ),
                ),
                _divider(),
                _row(
                  context,
                  Icons.dark_mode_rounded,
                  'Dark mode',
                  trailing: Switch(
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Privacy & safety'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _row(
                  context,
                  Icons.shield_rounded,
                  'Safety Center',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SafetyCenterScreen(),
                        ),
                      ),
                ),
                _divider(),
                _row(
                  context,
                  Icons.notifications_rounded,
                  'Notifications',
                  onTap: () => _comingSoon(context),
                ),
                _divider(),
                _row(
                  context,
                  Icons.visibility_rounded,
                  'Profile visibility',
                  onTap: () => _comingSoon(context),
                ),
                _divider(),
                _row(
                  context,
                  Icons.block_rounded,
                  'Blocked users',
                  onTap: () => _comingSoon(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Support'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _row(
                  context,
                  Icons.help_rounded,
                  'Help & FAQ',
                  onTap: () => _comingSoon(context),
                ),
                _divider(),
                _row(
                  context,
                  Icons.logout_rounded,
                  'Log out',
                  color: AppColors.red,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Center(
            child: Text(
              'Rumie · rumie.xyz',
              style: GoogleFonts.dmSans(color: AppColors.gray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Widget? trailing,
    String? trailingLabel,
    Color? trailingColor,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 20),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.text,
                ),
              ),
            ),
            if (trailingLabel != null)
              Text(
                trailingLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: trailingColor ?? AppColors.textSecondary,
                ),
              ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: AppColors.border);

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
              side: BorderSide(color: AppColors.border),
            ),
            title: Text(
              'Log out?',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            content: Text(
              'You can sign back in any time.',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.popUntil(context, (r) => r.isFirst);
                  context.read<AuthProvider>().logout();
                },
                child: Text(
                  'Log out',
                  style: GoogleFonts.dmSans(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
