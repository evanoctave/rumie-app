import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/roommate_card.dart';
import '../widgets/stamp.dart';

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

  void _handleSwipe(bool liked) {
    if (liked && _index < sampleRoommates.length) {
      HapticFeedback.heavyImpact();
      widget.onMatch(sampleRoommates[_index]);
      _showMatchDialog(sampleRoommates[_index]);
    }
    setState(() {
      _index = _index < sampleRoommates.length - 1 ? _index + 1 : sampleRoommates.length;
    });
  }

  void _showMatchDialog(Roommate roommate) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withAlpha(180),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (context, _, __) => _MatchDialog(
        roommate: roommate,
        onChat: () {
          Navigator.pop(context);
          widget.onOpenMatches();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _index < sampleRoommates.length;
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: hasMore ? _buildCardStack() : _buildEmpty()),
          if (hasMore) _buildActions(),
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
          const Text(
            'Discover',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
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
                  border: Border.all(color: AppColors.green.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.matchCount} match${widget.matchCount == 1 ? '' : 'es'}',
                      style: const TextStyle(
                        color: AppColors.green,
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
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCardStack() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_index + 2 < sampleRoommates.length)
            Transform.translate(
              offset: const Offset(0, 28),
              child: Transform.scale(
                scale: 0.90,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.3,
                    child: RoommateCard(roommate: sampleRoommates[_index + 2]),
                  ),
                ),
              ),
            ),
          if (_index + 1 < sampleRoommates.length)
            Transform.translate(
              offset: const Offset(0, 14),
              child: Transform.scale(
                scale: 0.95,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.55,
                    child: RoommateCard(roommate: sampleRoommates[_index + 1]),
                  ),
                ),
              ),
            ),
          _DragCard(
            key: ValueKey(_index),
            roommate: sampleRoommates[_index],
            onSwipe: _handleSwipe,
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
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/ic_discover.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            const SizedBox(height: 20),
            const Text(
              "You've seen everyone",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            const Text(
              'Check back soon for new profiles.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}

// ─── Draggable card ────────────────────────────────────────────────────────

class _DragCard extends StatefulWidget {
  final Roommate roommate;
  final void Function(bool) onSwipe;

  const _DragCard({super.key, required this.roommate, required this.onSwipe});

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
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _flyController  = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  }

  @override
  void dispose() {
    _snapController.dispose();
    _flyController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (_flying) return;
    _snapController.stop();
    _flyController.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_flying) return;
    setState(() => _offset += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_flying) return;
    const threshold = 110.0;
    final vel = d.velocity.pixelsPerSecond;
    if (_offset.dx > threshold || (vel.dx > 600 && _offset.dx > 40)) {
      _flyOff(true, vel);
    } else if (_offset.dx < -threshold || (vel.dx < -600 && _offset.dx < -40)) {
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
      liked ? sw * 1.8 : -sw * 1.8,
      (_offset.dy + velPps.dy * 0.1).clamp(-sh * 0.5, sh * 0.5),
    );
    _flyAnim = Tween<Offset>(begin: _offset, end: target)
        .animate(CurvedAnimation(parent: _flyController, curve: Curves.easeIn));
    _flyAnim.addListener(() => setState(() => _offset = _flyAnim.value));
    _flyController.forward().then((_) => widget.onSwipe(liked));
  }

  void _snapBack() {
    _snapAnim = Tween<Offset>(begin: _offset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _snapController, curve: Curves.elasticOut));
    _snapController.reset();
    _snapAnim.addListener(() => setState(() => _offset = _snapAnim.value));
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final rotation   = (_offset.dx / 400).clamp(-0.30, 0.30);
    final likeOpacity = (_offset.dx / 120).clamp(0.0, 1.0);
    final nopeOpacity = (-_offset.dx / 120).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            children: [
              RoommateCard(roommate: widget.roommate),
              if (likeOpacity > 0.05)
                Positioned(
                  top: 48,
                  left: 20,
                  child: Opacity(
                    opacity: likeOpacity.clamp(0.0, 1.0),
                    child: const Stamp(text: 'LIKE', color: AppColors.green),
                  ),
                ),
              if (nopeOpacity > 0.05)
                Positioned(
                  top: 48,
                  right: 20,
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

// ─── Match dialog ─────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AvatarBox(svgAsset: 'assets/icons/av_you.svg', gradient: roommate.gradient),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/ic_like.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(AppColors.green, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  _AvatarBox(svgAsset: roommate.avatarAsset, gradient: roommate.gradient),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "It's a Match!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              Text(
                'You and ${roommate.name} liked each other.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onChat,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Start Chatting',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Keep swiping',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: gradient.first.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SvgPicture.asset(svgAsset, fit: BoxFit.cover),
      ),
    );
  }
}
