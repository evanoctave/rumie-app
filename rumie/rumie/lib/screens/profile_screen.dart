import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/auth_provider.dart';
import '../state/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/app_chip.dart';
import '../widgets/ui/app_dialog.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/photo.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import 'home_screen.dart';
import 'profile_create_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEdit() {
    final provider = context.read<ProfileProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfileCreateScreen(
          existing: provider.profile,
          // Throws typed ApiExceptions; ProfileCreateScreen shows them.
          onSave: (updated) async {
            await provider.save(updated);
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showAppDialog(
      context,
      title: 'Log out?',
      message: 'You can sign back in anytime.',
      confirmLabel: 'Log out',
    );
    if (confirmed && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>().profile;
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(
            title: 'Profile',
            trailing: CircleButton(
              iconAsset: 'assets/icons/ic_settings.svg',
              semanticLabel: 'Settings',
              onTap: _openSettings,
            ),
          ),
        ),
        Expanded(
          child: p.isComplete ? _buildProfile(p, bottomPad) : _buildEmpty(bottomPad),
        ),
      ],
    );
  }

  Widget _buildEmpty(double bottomPad) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
        child: Reveal(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: AppShapes.shape(AppShapes.card, side: BorderSide(color: AppColors.line)),
              shadows: AppColors.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                  child: const Center(child: Text('✨', style: TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: 20),
                Text('Set up your profile', style: AppText.sectionTitle, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'A few details so the right roommates can find you.',
                  style: AppText.secondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(label: 'Create profile', onTap: _openEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(UserProfile p, double bottomPad) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: Row(
              children: [
                Avatar(path: p.photoPath, name: p.name, size: 88),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: AppText.cardName, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text('${p.age} · ${p.location}', style: AppText.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Reveal(index: 1, child: _StatsGrid(p: p)),
          if (p.bio.isNotEmpty) ...[
            const SizedBox(height: 28),
            Reveal(index: 2, child: Text('About', style: AppText.sectionTitle)),
            const SizedBox(height: 8),
            Reveal(index: 2, child: Text(p.bio, style: AppText.bodyLarge)),
          ],
          if (p.traits.isNotEmpty) ...[
            const SizedBox(height: 28),
            Reveal(index: 3, child: Text('Lifestyle', style: AppText.sectionTitle)),
            const SizedBox(height: 12),
            Reveal(
              index: 3,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < p.traits.length; i++)
                    AppChip(label: p.traits[i], style: i == 0 ? AppChipStyle.accent : AppChipStyle.neutral),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Reveal(index: 4, child: AppButton(label: 'Edit profile', iconAsset: 'assets/icons/ic_edit.svg', onTap: _openEdit)),
          const SizedBox(height: 8),
          Reveal(index: 5, child: AppButton(label: 'Log out', style: AppButtonStyle.ghost, onTap: _confirmLogout)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserProfile p;
  const _StatsGrid({required this.p});

  @override
  Widget build(BuildContext context) {
    final cells = [
      ('\$${p.budgetMin}–${p.budgetMax}', 'Budget per month'),
      (p.moveIn, 'Move-in'),
      (p.schedule, 'Schedule'),
      (p.tidiness, 'Tidiness'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        for (final c in cells)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.$1, style: AppText.stat, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(c.$2, style: AppText.caption),
              ],
            ),
          ),
      ],
    );
  }
}
