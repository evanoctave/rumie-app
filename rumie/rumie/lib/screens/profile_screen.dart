import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/user_profile.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final hasProfile = p.isComplete;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: hasProfile ? _buildProfile(p) : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_profile.svg',
                    width: 36,
                    height: 36,
                    colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 20),
              const Text(
                'Set up your profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              const Text(
                'Add your photo, bio, and preferences so potential roommates can find you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _openEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Create Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(UserProfile p) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(p),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildBioCard(p),
              const SizedBox(height: 16),
              _buildStatsRow(p),
              const SizedBox(height: 16),
              _buildPrefsCard(p),
              if (p.traits.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTraitsCard(p),
              ],
              const SizedBox(height: 28),
              _buildActionButtons(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(UserProfile p) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.surface,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _openEdit,
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        child: _buildAvatar(p),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${p.name}, ${p.age}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      p.location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
      return ClipOval(child: Image.file(File(p.photoPath), fit: BoxFit.cover));
    }
    return Center(
      child: SvgPicture.asset(
        'assets/icons/av_you.svg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBioCard(UserProfile p) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('About'),
          const SizedBox(height: 8),
          Text(
            p.bio,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfile p) {
    return Row(
      children: [
        _StatTile(label: 'Budget', value: '\$${p.budgetMin}–\$${p.budgetMax}'),
        const SizedBox(width: 10),
        _StatTile(label: 'Move-in', value: p.moveIn),
        const SizedBox(width: 10),
        _StatTile(label: 'Schedule', value: p.schedule),
      ],
    );
  }

  Widget _buildPrefsCard(UserProfile p) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Preferences'),
          const SizedBox(height: 10),
          _prefRow('Tidiness', p.tidiness),
          _prefRow('Pets', p.haspets ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _prefRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTraitsCard(UserProfile p) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel('Traits'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.traits.map((t) => _TraitPill(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _FullButton(
          label: 'Edit Profile',
          primary: true,
          onTap: _openEdit,
        ),
        const SizedBox(height: 10),
        _FullButton(
          label: 'Settings',
          primary: false,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _FullButton(
          label: 'Log Out',
          primary: false,
          danger: true,
          onTap: () {},
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
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
  const _TraitPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FullButton extends StatelessWidget {
  final String label;
  final bool primary;
  final bool danger;
  final VoidCallback onTap;

  const _FullButton({
    required this.label,
    required this.primary,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color borderColor;

    if (primary) {
      bg = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (danger) {
      bg = AppColors.softRed;
      textColor = AppColors.red;
      borderColor = AppColors.red.withAlpha(60);
    } else {
      bg = AppColors.cardBg;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.border;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
