import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '←',
                      style: GoogleFonts.syne(
                          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  const _SectionLabel('APPEARANCE'),
                  _ToggleRow(
                    label: 'Dark mode',
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                  ),
                  const _SectionLabel('DISCOVERY'),
                  _NavRow(label: 'Max distance', value: '10 miles', onTap: () {}),
                  _ToggleRow(label: 'Verified only', value: false, onChanged: (_) {}),
                  _NavRow(label: 'Budget filter', value: '\$800–\$1,800', onTap: () {}),
                  const _SectionLabel('NOTIFICATIONS'),
                  _ToggleRow(label: 'New matches', value: true, onChanged: (_) {}),
                  _ToggleRow(label: 'Messages', value: true, onChanged: (_) {}),
                  _ToggleRow(label: 'Listing alerts', value: false, onChanged: (_) {}),
                  const _SectionLabel('ACCOUNT'),
                  _DangerRow(label: 'Sign out', onTap: () => auth.logout()),
                  _DangerRow(
                    label: 'Delete account',
                    onTap: () => _confirmDelete(context, auth),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border, width: 1.5),
        ),
        title: Text(
          'Delete account?',
          style: GoogleFonts.syne(
              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        content: Text(
          'This cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                  color: AppColors.scoreLow, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _NavRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _NavRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                '›',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
}

class _DangerRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DangerRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.scoreLow),
          ),
        ),
      );
}
