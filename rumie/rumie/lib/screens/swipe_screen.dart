import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/utils/profile_styles.dart';
import '../domain/entities/roommate_candidate.dart';
import '../domain/entities/roommate_profile.dart';
import '../state/discovery_provider.dart';
import '../state/matches_provider.dart';
import '../state/saved_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/match_score_pill.dart';
import '../widgets/rumie_chip.dart';
import '../widgets/save_button.dart';
import '../widgets/stamp.dart';
import 'chat_screen.dart';
import 'roommate_detail_screen.dart';

/// Discover tab: swipe through compatible roommates.
class SwipeScreen extends StatefulWidget {
  final VoidCallback onOpenMatches;

  const SwipeScreen({super.key, required this.onOpenMatches});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  double _dragRatio = 0.0;

  @override
  void initState() {
    super.initState();
    final discovery = context.read<DiscoveryProvider>();
    if (discovery.loading) discovery.load();
  }

  void _onDragRatio(double ratio) {
    setState(() => _dragRatio = ratio.clamp(-1.0, 1.0));
  }

  Color get _bgColor {
    final bg = AppColors.background;
    if (_dragRatio > 0) {
      return Color.lerp(bg, const Color(0xFFD1FAE5), _dragRatio * 0.85) ?? bg;
    } else if (_dragRatio < 0) {
      return Color.lerp(bg, const Color(0xFFFEE2E2), -_dragRatio * 0.85) ?? bg;
    }
    return bg;
  }

  void _handleSwipe(bool liked) {
    final discovery = context.read<DiscoveryProvider>();
    final candidate = discovery.current;
    if (candidate == null) return;

    setState(() => _dragRatio = 0.0);

    if (liked) {
      HapticFeedback.heavyImpact();
      discovery.like(candidate);
      final isNew = context.read<MatchesProvider>().addFromCandidate(candidate);
      if (isNew) _showMatchDialog(candidate);
    } else {
      discovery.pass(candidate);
    }
  }

  void _openDetail(RoommateCandidate candidate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RoommateDetailScreen(
              candidate: candidate,
              onLike: () => _handleSwipe(true),
            ),
      ),
    );
  }

  void _showMatchDialog(RoommateCandidate candidate) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withAlpha(160),
      transitionDuration: const Duration(milliseconds: 420),
      transitionBuilder: (context, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
        );
      },
      pageBuilder:
          (dialogContext, anim, secAnim) => Material(
            type: MaterialType.transparency,
            child: _MatchDialog(
              profile: candidate.profile,
              onChat: () {
                Navigator.pop(dialogContext);
                final match = context
                    .read<MatchesProvider>()
                    .matches
                    .firstWhere((m) => m.profile.id == candidate.profile.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(match: match)),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryProvider>();
    final current = discovery.current;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      color: _bgColor,
      child: Column(
        children: [
          _buildHeader(),
          _buildFilters(discovery),
          if (discovery.loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            )
          else if (current != null) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
                child: Column(
                  children: [
                    const SizedBox(height: Spacing.sm),
                    Center(child: _buildPhotoStack(discovery)),
                    const SizedBox(height: Spacing.lg),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            ),
                        child: _buildProfileInfo(current),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(),
            const SizedBox(height: 110), // space for floating nav
          ] else
            Expanded(child: _buildEmpty(discovery)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final matchCount = context.watch<MatchesProvider>().count;

    return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.xl,
            Spacing.gutter,
            Spacing.sm,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Find your people',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'Roommates who actually fit your lifestyle',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (matchCount > 0)
                GestureDetector(
                  onTap: widget.onOpenMatches,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(Radii.sm),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '$matchCount match${matchCount == 1 ? '' : 'es'}',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildFilters(DiscoveryProvider discovery) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: DiscoverFilter.values.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final filter = DiscoverFilter.values[index];
          return Center(
            child: RumieChip(
              label: filter.label,
              selected: discovery.filters.contains(filter),
              onTap: () => discovery.toggleFilter(filter),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 300.ms);
  }

  Widget _buildPhotoStack(DiscoveryProvider discovery) {
    const size = 190.0;
    const stackHeight = size + 24.0;
    final current = discovery.current!;
    final next = discovery.next;
    final afterNext = discovery.afterNext;

    return SizedBox(
      width: size,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (afterNext != null)
            Positioned(
              top: 24,
              child: Opacity(
                opacity: 0.20,
                child: Transform.scale(
                  scale: 0.84,
                  child: _AvatarCircle(profile: afterNext.profile, size: size),
                ),
              ),
            ),
          if (next != null)
            Positioned(
              top: 12,
              child: Opacity(
                opacity: 0.55,
                child: Transform.scale(
                  scale: 0.92,
                  child: _AvatarCircle(profile: next.profile, size: size),
                ),
              ),
            ),
          Positioned(
            top: 0,
            child: _DragCard(
              key: ValueKey(current.profile.id),
              profile: current.profile,
              onSwipe: _handleSwipe,
              onDragRatio: _onDragRatio,
              onTap: () => _openDetail(current),
              size: size,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(RoommateCandidate candidate) {
    final p = candidate.profile;
    final saved = context.watch<SavedProvider>().isRoommateSaved(p.id);

    return SizedBox(
      key: ValueKey(p.id),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${p.name}, ${p.age}',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                MatchScorePill(
                  score: candidate.compatibilityScore,
                  large: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 14,
                  color: AppColors.primary.withAlpha(180),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${p.major} · ${p.school}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SaveButton(
                  saved: saved,
                  heart: true,
                  size: 34,
                  onToggle:
                      () => context.read<SavedProvider>().toggleRoommate(p.id),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                _infoPill(
                  Icons.payments_rounded,
                  p.budgetLabel,
                  AppColors.greenDark,
                  AppColors.softGreen,
                ),
                const SizedBox(width: Spacing.sm),
                _infoPill(
                  Icons.calendar_today_rounded,
                  p.moveInLabel,
                  AppColors.darkMauve,
                  AppColors.softPurple,
                ),
              ],
            ),
            if (candidate.compatibilityReasons.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: AppColors.borderBright, width: 1),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final reason in candidate.compatibilityReasons.take(3))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.pink,
                              size: 13,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Text(
                                reason,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    GestureDetector(
                      onTap: () => _openDetail(candidate),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'See full profile →',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            Text(
              p.bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                for (final tag in p.lifestyleTags)
                  RumieChip(label: tag, color: ProfileStyles.tagColor(tag)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: fg.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionButton(
                label: 'Pass',
                svgAsset: 'assets/icons/ic_pass.svg',
                color: AppColors.red,
                onTap: () => _handleSwipe(false),
              ),
              ActionButton(
                label: 'Super',
                svgAsset: 'assets/icons/ic_super.svg',
                color: AppColors.yellow,
                onTap: () => _handleSwipe(true),
                large: true,
              ),
              ActionButton(
                label: 'Like',
                svgAsset: 'assets/icons/ic_like.svg',
                color: AppColors.green,
                onTap: () => _handleSwipe(true),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildEmpty(DiscoveryProvider discovery) {
    final filtered = discovery.filters.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/ic_discover.svg',
                      width: 44,
                      height: 44,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 28),
            Text(
              filtered ? 'No one fits those filters' : "You've seen everyone",
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 10),
            Text(
              filtered
                  ? 'Try removing a filter to see more people.'
                  : 'Check back soon for new profiles.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 240.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar circle ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final RoommateProfile profile;
  final double size;

  const _AvatarCircle({required this.profile, required this.size});

  @override
  Widget build(BuildContext context) {
    final gradient = ProfileStyles.gradientFor(profile.id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [gradient.first.withAlpha(80), gradient.last.withAlpha(40)],
        ),
        border: Border.all(color: gradient.first.withAlpha(120), width: 3),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withAlpha(60),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(profile.avatarAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ─── Draggable photo ───────────────────────────────────────────────────────────

class _DragCard extends StatefulWidget {
  final RoommateProfile profile;
  final void Function(bool) onSwipe;
  final void Function(double) onDragRatio;
  final VoidCallback onTap;
  final double size;

  const _DragCard({
    super.key,
    required this.profile,
    required this.onSwipe,
    required this.onDragRatio,
    required this.onTap,
    required this.size,
  });

  @override
  State<_DragCard> createState() => _DragCardState();
}

class _DragCardState extends State<_DragCard> with TickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _flying = false;

  late AnimationController _snapController;
  late Animation<Offset> _snapAnim;
  late AnimationController _flyController;
  late Animation<Offset> _flyAnim;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    _flyController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    if (_flying) return;
    _snapController.stop();
    _flyController.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_flying) return;
    setState(() => _offset += d.delta);
    final sw = MediaQuery.of(context).size.width;
    widget.onDragRatio(_offset.dx / (sw * 0.42));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_flying) return;
    const threshold = 90.0;
    final vel = d.velocity.pixelsPerSecond;
    if (_offset.dx > threshold || (vel.dx > 450 && _offset.dx > 25)) {
      _flyOff(true, vel);
    } else if (_offset.dx < -threshold || (vel.dx < -450 && _offset.dx < -25)) {
      _flyOff(false, vel);
    } else {
      _snapBack();
    }
  }

  void _flyOff(bool liked, Offset velPps) {
    _flying = true;
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final target = Offset(
      liked ? sw * 2.0 : -sw * 2.0,
      (_offset.dy + velPps.dy * 0.07).clamp(-sh * 0.4, sh * 0.4),
    );
    _flyAnim = Tween<Offset>(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _flyController, curve: Curves.easeIn));
    _flyAnim.addListener(() {
      setState(() => _offset = _flyAnim.value);
      widget.onDragRatio((_flyAnim.value.dx / (sw * 0.42)).clamp(-1.0, 1.0));
    });
    _flyController.forward().then((_) => widget.onSwipe(liked));
  }

  void _snapBack() {
    _snapAnim = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
    _snapController.reset();
    _snapAnim.addListener(() {
      setState(() => _offset = _snapAnim.value);
      widget.onDragRatio(_snapAnim.value.dx / 100.0);
    });
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final rotation = (_offset.dx / 500).clamp(-0.28, 0.28);
    final likeOpacity = (_offset.dx / 75).clamp(0.0, 1.0);
    final nopeOpacity = (-_offset.dx / 75).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _AvatarCircle(profile: widget.profile, size: widget.size),
              if (likeOpacity > 0.04)
                Positioned(
                  top: 12,
                  left: 4,
                  child: Opacity(
                    opacity: likeOpacity.clamp(0.0, 1.0),
                    child: const Stamp(text: 'LIKE', color: AppColors.green),
                  ),
                ),
              if (nopeOpacity > 0.04)
                Positioned(
                  top: 12,
                  right: 4,
                  child: Opacity(
                    opacity: nopeOpacity.clamp(0.0, 1.0),
                    child: const Stamp(text: 'NOPE', color: AppColors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Match dialog ──────────────────────────────────────────────────────────────

class _MatchDialog extends StatelessWidget {
  final RoommateProfile profile;
  final VoidCallback onChat;

  const _MatchDialog({required this.profile, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final gradient = ProfileStyles.gradientFor(profile.id);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.floatingShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti-like colored dots row
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(AppColors.pink),
                      const SizedBox(width: 4),
                      _dot(AppColors.yellow),
                      const SizedBox(width: 4),
                      _dot(AppColors.green),
                      const SizedBox(width: 4),
                      _dot(AppColors.primary),
                      const SizedBox(width: 4),
                      _dot(AppColors.orange),
                    ],
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withAlpha(60),
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AvatarBox(
                    svgAsset: 'assets/icons/av_you.svg',
                    gradient: gradient,
                  ),
                  Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.buttonShadow,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ic_like.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 0.88,
                        end: 1.14,
                        duration: 800.ms,
                        curve: Curves.easeInOut,
                      ),
                  _AvatarBox(svgAsset: profile.avatarAsset, gradient: gradient),
                ],
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback:
                    (b) => AppColors.primaryGradient.createShader(b),
                child: Text(
                  "It's a Match!",
                  style: GoogleFonts.dmSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and ${profile.name} liked each other.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onChat,
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
                      'Start Chatting',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Keep swiping',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AvatarBox extends StatelessWidget {
  final String svgAsset;
  final List<Color> gradient;

  const _AvatarBox({required this.svgAsset, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient.first.withAlpha(80), gradient.last.withAlpha(40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient.first.withAlpha(100), width: 2),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
