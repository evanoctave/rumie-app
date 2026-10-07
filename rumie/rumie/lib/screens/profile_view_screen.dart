import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/entities/entities.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../widgets/avatar_style.dart';
import '../widgets/discover_card.dart';
import '../widgets/rumie_icon.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/app_chip.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/reveal.dart';

/// Full candidate profile. The art flies in from the discover card and
/// stretches on overscroll. Pops with `true` on Connect, `false` on Pass,
/// `null` on back.
class ProfileViewScreen extends StatelessWidget {
  final RoommateCandidate candidate;
  const ProfileViewScreen({super.key, required this.candidate});

  static PageRoute<bool> route(RoommateCandidate c) {
    return PageRouteBuilder<bool>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => ProfileViewScreen(candidate: c),
      transitionsBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final width = MediaQuery.sizeOf(context).width;
    final photoHeight = (width * 1.18).clamp(380.0, 560.0);
    final safeTop = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: photoHeight,
                toolbarHeight: 0,
                collapsedHeight: 0,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.background,
                stretch: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: ClipRSuperellipse(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(tag: DiscoverCard.heroTag(c), child: CandidateArt(candidate: c)),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 220,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.photoInk.withValues(alpha: 0),
                                  AppColors.photoInk.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 26,
                          child: Reveal(
                            offsetY: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.name,
                                  style: AppText.hero.copyWith(fontSize: 40, color: AppColors.photoText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    RumieIcon(asset: 'assets/icons/ic_location.svg', size: 15, color: AppColors.photoText.withValues(alpha: 0.85)),
                                    const SizedBox(width: 5),
                                    Text(
                                      c.ageLabel.isEmpty ? c.location : '${c.ageLabel} · ${c.location}',
                                      style: AppText.bodyMedium.copyWith(color: AppColors.photoText.withValues(alpha: 0.88)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 140),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Reveal(index: 1, child: _Facts(candidate: c)),
                    const SizedBox(height: 28),
                    Reveal(index: 2, child: Text('About', style: AppText.sectionTitle)),
                    const SizedBox(height: 8),
                    Reveal(index: 2, child: Text(c.bio, style: AppText.bodyLarge)),
                    if (c.tags.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Reveal(index: 3, child: Text('Lifestyle', style: AppText.sectionTitle)),
                      const SizedBox(height: 12),
                      Reveal(
                        index: 3,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < c.tags.length; i++)
                              AppChip(label: c.tags[i], style: i == 0 ? AppChipStyle.accent : AppChipStyle.neutral),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: safeTop + 10,
            left: 16,
            child: CircleButton(
              iconAsset: 'assets/icons/ic_back.svg',
              style: CircleButtonStyle.onPhoto,
              semanticLabel: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ActionBar(
              onPass: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(false);
              },
              onConnect: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  final RoommateCandidate candidate;
  const _Facts({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final cells = [
      (c.budget != null ? '\$${c.budget}' : '—', 'per month'),
      (c.ageLabel.isEmpty ? '—' : c.ageLabel, 'age range'),
      (c.location, 'availability'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, thickness: 1, color: AppColors.line),
              Expanded(
                child: Column(
                  children: [
                    Text(cells[i].$1, style: AppText.stat, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(cells[i].$2, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onConnect;
  const _ActionBar({required this.onPass, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
          stops: const [0, 0.4],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Reveal(
            index: 2,
            offsetY: 24,
            child: Row(
              children: [
                CircleButton(
                  size: 56,
                  iconAsset: 'assets/icons/ic_close.svg',
                  semanticLabel: 'Pass',
                  onTap: onPass,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Connect',
                    iconAsset: 'assets/icons/ic_like.svg',
                    onTap: onConnect,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
