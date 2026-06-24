import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/auth_provider.dart';
import '../theme/app_colors.dart';
import 'profile_create_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserProfile) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileCreateScreen(
          existing: widget.profile,
          onSave: (updated) {
            widget.onProfileUpdated(updated);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border, width: 1.5),
        ),
        title: Text(
          'Log out?',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            fontSize: 18,
          ),
        ),
        content: Text(
          'You can sign back in anytime.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(
                color: AppColors.scoreLow,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: p.isComplete ? _buildProfile(p) : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return SafeArea(
      child: Column(
        children: [
          const _Header(trailing: null),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NO\nPROFILE\nYET',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syne(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -2,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Set up your profile so\nroommates can find you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _FlatBtn(
                      label: 'CREATE PROFILE →',
                      onTap: _openEdit,
                      primary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(UserProfile p) {
    return SafeArea(
      child: Column(
        children: [
          _Header(
            trailing: GestureDetector(
              onTap: _openEdit,
              child: Text(
                'EDIT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(onTap: _openEdit, child: _Avatar(p: p)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name.toUpperCase(),
                              style: GoogleFonts.syne(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -1.5,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.age} · ${p.location}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.border, thickness: 1.5, height: 1),
                  const SizedBox(height: 20),
                  const _SectionLabel('DETAILS'),
                  const SizedBox(height: 8),
                  _StatsGrid(p: p),
                  const SizedBox(height: 20),
                  if (p.bio.isNotEmpty) ...[
                    const _SectionLabel('ABOUT'),
                    const SizedBox(height: 8),
                    Text(
                      p.bio,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.text, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (p.traits.isNotEmpty) ...[
                    const _SectionLabel('TRAITS'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: p.traits
                          .asMap()
                          .entries
                          .map((e) =>
                              _TraitChip(trait: e.value, accent: e.key == 0))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Divider(color: AppColors.border, thickness: 1.5, height: 1),
                  const SizedBox(height: 20),
                  _FlatBtn(label: 'EDIT PROFILE', onTap: _openEdit, primary: true),
                  const SizedBox(height: 8),
                  _FlatBtn(label: 'SETTINGS', onTap: _openSettings, primary: false),
                  const SizedBox(height: 8),
                  _FlatBtn(
                    label: 'LOG OUT',
                    onTap: _confirmLogout,
                    primary: false,
                    danger: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Widget? trailing;
  const _Header({required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: Row(
          children: [
            Text(
              'Profile',
              style: GoogleFonts.syne(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.8,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _Avatar extends StatelessWidget {
  final UserProfile p;
  const _Avatar({required this.p});

  @override
  Widget build(BuildContext context) {
    if (p.photoPath.isNotEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(File(p.photoPath), fit: BoxFit.cover),
        ),
      );
    }
    final initial = p.name.isNotEmpty ? p.name[0].toUpperCase() : '?';
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.syne(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      );
}

class _StatsGrid extends StatelessWidget {
  final UserProfile p;
  const _StatsGrid({required this.p});

  @override
  Widget build(BuildContext context) {
    final cells = [
      ('\$${p.budgetMin}–${p.budgetMax}/mo', 'BUDGET'),
      (p.moveIn, 'MOVE-IN'),
      (p.schedule, 'SCHEDULE'),
      (p.tidiness, 'TIDINESS'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: cells
          .map((c) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSoft, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.$1,
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      c.$2,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final String trait;
  final bool accent;
  const _TraitChip({required this.trait, required this.accent});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent ? AppColors.chipBg : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: accent ? AppColors.chipBg : AppColors.borderSoft,
          ),
        ),
        child: Text(
          trait.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: accent ? AppColors.chipText : AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      );
}

class _FlatBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  const _FlatBtn({
    required this.label,
    required this.onTap,
    required this.primary,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: danger
                ? AppColors.softRed
                : primary
                    ? AppColors.btnPrimary
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: danger
                  ? AppColors.scoreLow
                  : primary
                      ? AppColors.btnPrimary
                      : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: danger
                  ? AppColors.scoreLow
                  : primary
                      ? AppColors.btnPrimaryText
                      : AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ),
      );
}
