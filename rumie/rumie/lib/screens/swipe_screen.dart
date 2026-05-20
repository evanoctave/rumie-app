import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/stamp.dart';
import '../widgets/trait_chip.dart';

class SwipeScreen extends StatefulWidget {
  final void Function(Roommate) onMatch;
  final int matchCount;
  final VoidCallback onOpenMatches;

  const SwipeScreen({
    super.key,
    required this.onMatch,
    required this.matchCount,
    required this.onOpenMatches,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  int _index = 0;
  double _dragRatio = 0.0;

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
    if (liked && _index < sampleRoommates.length) {
      HapticFeedback.heavyImpact();
      widget.onMatch(sampleRoommates[_index]);
      _showMatchDialog(sampleRoommates[_index]);
    }
    setState(() {
      _dragRatio = 0.0;
      _index = _index < sampleRoommates.length - 1 ? _index + 1 : sampleRoommates.length;
    });
  }

  void _showMatchDialog(Roommate roommate) {
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
      pageBuilder: (context, anim, secAnim) => Material(
        type: MaterialType.transparency,
        child: _MatchDialog(
          roommate: roommate,
          onChat: () {
            Navigator.pop(context);
            widget.onOpenMatches();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _index < sampleRoommates.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      color: _bgColor,
      child: Column(
        children: [
          _buildHeader(),
          if (hasMore) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Center(child: _buildPhotoStack()),
                    const SizedBox(height: 24),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        ),
                        child: _buildProfileInfo(sampleRoommates[_index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(),
            const SizedBox(height: 110), // space for floating nav
          ] else
            Expanded(child: _buildEmpty()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Discover',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'Find your perfect roommate',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.matchCount > 0)
            GestureDetector(
              onTap: widget.onOpenMatches,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.matchCount} match${widget.matchCount == 1 ? '' : 'es'}',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildPhotoStack() {
    const size = 200.0;
    const stackHeight = size + 24.0;

    return SizedBox(
      width: size,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (_index + 2 < sampleRoommates.length)
            Positioned(
              top: 24,
              child: Opacity(
                opacity: 0.20,
                child: Transform.scale(
                  scale: 0.84,
                  child: _AvatarCircle(
                    roommate: sampleRoommates[_index + 2],
                    size: size,
                  ),
                ),
              ),
            ),
          if (_index + 1 < sampleRoommates.length)
            Positioned(
              top: 12,
              child: Opacity(
                opacity: 0.55,
                child: Transform.scale(
                  scale: 0.92,
                  child: _AvatarCircle(
                    roommate: sampleRoommates[_index + 1],
                    size: size,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            child: _DragCard(
              key: ValueKey(_index),
              roommate: sampleRoommates[_index],
              onSwipe: _handleSwipe,
              onDragRatio: _onDragRatio,
              size: size,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(Roommate r) {
    return SizedBox(
      key: ValueKey(r.name),
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
                    '${r.name}, ${r.age}',
                    style: GoogleFonts.dmSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green.withAlpha(60)),
                  ),
                  child: Text(
                    '\$${r.budget}/mo',
                    style: GoogleFonts.dmSans(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary.withAlpha(180)),
                const SizedBox(width: 4),
                Text(
                  r.location,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                r.bio,
                style: GoogleFonts.dmSans(
                  fontSize: 14.5,
                  height: 1.6,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: r.traits.map((t) => TraitChip(trait: t)).toList(),
            ),
          ],
        ),
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

  Widget _buildEmpty() {
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
                  colors: [AppColors.softPurple, Color(0xFFE0D9FF)],
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
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 28),
            Text(
              "You've seen everyone",
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 10),
            Text(
              'Check back soon for new profiles.',
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
  final Roommate roommate;
  final double size;

  const _AvatarCircle({required this.roommate, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            roommate.gradient.first.withAlpha(80),
            roommate.gradient.last.withAlpha(40),
          ],
        ),
        border: Border.all(color: roommate.gradient.first.withAlpha(120), width: 3),
        boxShadow: [
          BoxShadow(
            color: roommate.gradient.first.withAlpha(60),
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
          child: SvgPicture.asset(roommate.avatarAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ─── Draggable photo ───────────────────────────────────────────────────────────

class _DragCard extends StatefulWidget {
  final Roommate roommate;
  final void Function(bool) onSwipe;
  final void Function(double) onDragRatio;
  final double size;

  const _DragCard({
    super.key,
    required this.roommate,
    required this.onSwipe,
    required this.onDragRatio,
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
    _flyAnim = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeIn),
    );
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
              _AvatarCircle(roommate: widget.roommate, size: widget.size),
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
  final Roommate roommate;
  final VoidCallback onChat;

  const _MatchDialog({required this.roommate, required this.onChat});

  @override
  Widget build(BuildContext context) {
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
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 1200.ms, color: Colors.white.withAlpha(60)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AvatarBox(svgAsset: 'assets/icons/av_you.svg', gradient: roommate.gradient),
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
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.88, end: 1.14, duration: 800.ms, curve: Curves.easeInOut),
                  _AvatarBox(svgAsset: roommate.avatarAsset, gradient: roommate.gradient),
                ],
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
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
                'You and ${roommate.name} liked each other.',
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
