import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_colors.dart';
import 'profile_create_screen.dart';

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
        builder:
            (_) => ProfileCreateScreen(
              existing: widget.profile,
              onSave: (updated) {
                widget.onProfileUpdated(updated);
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: p.isComplete ? _buildProfile(p) : _buildEmpty(),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.softPurple, const Color(0xFFE0D9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_profile.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Set up your profile',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 10),
              Text(
                'Add your photo, bio, and preferences so\npotential roommates can find you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              _PrimaryButton(label: 'Create Profile', onTap: _openEdit)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.12, end: 0, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full profile ─────────────────────────────────────────────────────────────

  Widget _buildProfile(UserProfile p) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(p),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildBioCard(p),
              const SizedBox(height: 14),
              _buildStatsRow(p),
              const SizedBox(height: 14),
              _buildPrefsCard(p),
              if (p.traits.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildTraitsCard(p),
              ],
              const SizedBox(height: 28),
              _buildActions(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(UserProfile p) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.softPurple, const Color(0xFFF5F0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openEdit,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: AppColors.floatingShadow,
                        ),
                        child: ClipOval(child: _buildAvatar(p)),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${p.name}, ${p.age}',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      p.location,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildAvatar(UserProfile p) {
    if (p.photoPath.isNotEmpty) {
      return Image.file(File(p.photoPath), fit: BoxFit.cover);
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset('assets/icons/av_you.svg', fit: BoxFit.contain),
    );
  }

  Widget _buildBioCard(UserProfile p) {
    return _Card(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('About', color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            p.bio,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.text,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfile p) {
    return Row(
      children: [
        _StatTile(
          label: 'Budget',
          value: '\$${p.budgetMin}–${p.budgetMax}',
          color: AppColors.green,
        ),
        const SizedBox(width: 10),
        _StatTile(label: 'Move-in', value: p.moveIn, color: AppColors.orange),
        const SizedBox(width: 10),
        _StatTile(label: 'Schedule', value: p.schedule, color: AppColors.blue),
      ],
    );
  }

  Widget _buildPrefsCard(UserProfile p) {
    return _Card(
      accentColor: AppColors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Preferences', color: AppColors.teal),
          const SizedBox(height: 12),
          _prefRow('Tidiness', p.tidiness, AppColors.teal),
          _prefRow('Pets', p.haspets ? 'Yes' : 'No', AppColors.yellow),
        ],
      ),
    );
  }

  Widget _prefRow(String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsCard(UserProfile p) {
    return _Card(
      accentColor: AppColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Traits', color: AppColors.pink),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                p.traits
                    .asMap()
                    .entries
                    .map((e) => _TraitPill(e.value, _traitColor(e.key)))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Color _traitColor(int i) {
    const colors = [
      AppColors.primary,
      AppColors.green,
      AppColors.pink,
      AppColors.orange,
      AppColors.blue,
      AppColors.teal,
    ];
    return colors[i % colors.length];
  }

  Widget _buildActions() {
    return Column(
      children: [
        _PrimaryButton(label: 'Edit Profile', onTap: _openEdit),
        const SizedBox(height: 10),
        _SecondaryButton(label: 'Settings', onTap: () => _openSettings()),
        const SizedBox(height: 10),
        _DangerButton(label: 'Log Out', onTap: () => _confirmLogout()),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    final themeProvider = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (_, setSheet) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MediaQuery.of(ctx).padding.bottom + 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Settings',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Dark mode toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.softPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                themeProvider.isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Dark Mode',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Switch(
                              value: themeProvider.isDark,
                              onChanged: (v) {
                                themeProvider.setDark(v);
                                setSheet(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.border, height: 1),
                      const _SettingsTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        badge: 'Soon',
                      ),
                      Divider(color: AppColors.border, height: 1),
                      const _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Privacy & Security',
                        badge: 'Soon',
                      ),
                      Divider(color: AppColors.border, height: 1),
                      const _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        badge: 'Soon',
                      ),
                      Divider(color: AppColors.border, height: 1),
                      const _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About Rumie v0.1.0',
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            title: Text(
              'Log out?',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                fontSize: 18,
              ),
            ),
            content: Text(
              'You can sign back in anytime.',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.dmSans(
                    color: AppColors.red,
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
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _Card({required this.child, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(30), width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _CardLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TraitPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.softRed,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withAlpha(50), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: AppColors.red,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;

  const _SettingsTile({required this.icon, required this.label, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.softYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: GoogleFonts.dmSans(
                  color: AppColors.yellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.gray),
        ],
      ),
    );
  }
}
