import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  double _dragRatio = 0.0; // -1 (full left) → +1 (full right)

  void _onDragRatio(double ratio) {
    setState(() => _dragRatio = ratio.clamp(-1.0, 1.0));
  }

  Color get _bgColor {
    const bg = AppColors.background;
    if (_dragRatio > 0) {
      return Color.lerp(bg, const Color(0xFF082A10), _dragRatio * 0.8) ?? bg;
    } else if (_dragRatio < 0) {
      return Color.lerp(bg, const Color(0xFF2A0808), -_dragRatio * 0.8) ?? bg;
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
      barrierColor: Colors.black.withAlpha(180),
      transitionDuration: const Duration(milliseconds: 380),
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
      duration: const Duration(milliseconds: 50),
      color: _bgColor,
      child: Column(
        children: [
          _buildHeader(),
          if (hasMore) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(child: _buildPhotoStack()),
                    const SizedBox(height: 28),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            )),
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
          ] else
            Expanded(child: _buildEmpty()),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Discover',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const Spacer(),
          if (widget.matchCount > 0)
            GestureDetector(
              onTap: widget.onOpenMatches,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.matchCount} match${widget.matchCount == 1 ? '' : 'es'}',
                      style: const TextStyle(
                        color: AppColors.primary,
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
    const size = 188.0;
    const stackHeight = size + 22.0;

    return SizedBox(
      width: size,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (_index + 2 < sampleRoommates.length)
            Positioned(
              top: 22,
              child: Opacity(
                opacity: 0.18,
                child: Transform.scale(
                  scale: 0.86,
                  child: _PhotoCircle(
                    roommate: sampleRoommates[_index + 2],
                    size: size,
                  ),
                ),
              ),
            ),
          if (_index + 1 < sampleRoommates.length)
            Positioned(
              top: 11,
              child: Opacity(
                opacity: 0.45,
                child: Transform.scale(
                  scale: 0.93,
                  child: _PhotoCircle(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${r.name}, ${r.age}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: Text(
                  '\$${r.budget}/mo',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic_location.svg',
                width: 13,
                height: 13,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                r.location,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            r.bio,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: r.traits.map((t) => TraitChip(trait: t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
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
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
          begin: 0.3,
          end: 0,
          delay: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cardBg, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/ic_discover.svg',
                  width: 42,
                  height: 42,
                  colorFilter: const ColorFilter.mode(
                    AppColors.mauve,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: 24),
            const Text(
              "You've seen everyone",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.5),
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 10),
            const Text(
              'Check back soon for new profiles.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ).animate().fadeIn(delay: 240.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Photo circle ──────────────────────────────────────────────────────────

class _PhotoCircle extends StatelessWidget {
  final Roommate roommate;
  final double size;

  const _PhotoCircle({required this.roommate, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: roommate.gradient.first.withAlpha(60),
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            roommate.gradient.first.withAlpha(100),
            roommate.gradient.last.withAlpha(60),
          ],
        ),
        border: Border.all(
          color: Colors.white.withAlpha(18),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: roommate.gradient.first.withAlpha(60),
            blurRadius: 32,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.asset(roommate.avatarAsset, fit: BoxFit.cover),
      ),
    );
  }
}

// ─── Draggable photo ───────────────────────────────────────────────────────

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
      duration: const Duration(milliseconds: 420),
    );
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
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
    widget.onDragRatio(_offset.dx / (sw * 0.45));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_flying) return;
    const threshold = 100.0;
    final vel = d.velocity.pixelsPerSecond;
    if (_offset.dx > threshold || (vel.dx > 500 && _offset.dx > 30)) {
      _flyOff(true, vel);
    } else if (_offset.dx < -threshold || (vel.dx < -500 && _offset.dx < -30)) {
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
      (_offset.dy + velPps.dy * 0.08).clamp(-sh * 0.4, sh * 0.4),
    );
    _flyAnim = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeIn),
    );
    _flyAnim.addListener(() {
      setState(() => _offset = _flyAnim.value);
      widget.onDragRatio((_flyAnim.value.dx / (sw * 0.45)).clamp(-1.0, 1.0));
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
      widget.onDragRatio(_snapAnim.value.dx / 120.0);
    });
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final rotation = (_offset.dx / 480).clamp(-0.30, 0.30);
    final likeOpacity = (_offset.dx / 80).clamp(0.0, 1.0);
    final nopeOpacity = (-_offset.dx / 80).clamp(0.0, 1.0);

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
              _PhotoCircle(roommate: widget.roommate, size: widget.size),
              if (likeOpacity > 0.04)
                Positioned(
                  top: 14,
                  left: 6,
                  child: Opacity(
                    opacity: likeOpacity.clamp(0.0, 1.0),
                    child: const Stamp(text: 'LIKE', color: AppColors.primary),
                  ),
                ),
              if (nopeOpacity > 0.04)
                Positioned(
                  top: 14,
                  right: 6,
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

// ─── Match dialog ──────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(20),
                blurRadius: 40,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AvatarBox(
                    svgAsset: 'assets/icons/av_you.svg',
                    gradient: roommate.gradient,
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/ic_like.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.9, end: 1.1, duration: 800.ms, curve: Curves.easeInOut),
                  _AvatarBox(
                    svgAsset: roommate.avatarAsset,
                    gradient: roommate.gradient,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ShaderMask(
                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                child: const Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: 28,
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
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: onChat,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start Chatting',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Keep swiping',
                  style: TextStyle(
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
}

class _AvatarBox extends StatelessWidget {
  final String svgAsset;
  final List<Color> gradient;

  const _AvatarBox({required this.svgAsset, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.first.withAlpha(100),
            gradient.last.withAlpha(60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SvgPicture.asset(svgAsset, fit: BoxFit.cover),
      ),
    );
  }
}
