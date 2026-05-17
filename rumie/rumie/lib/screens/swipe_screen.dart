import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/animated_background.dart';
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
      _index = _index < sampleRoommates.length - 1
          ? _index + 1
          : sampleRoommates.length;
    });
  }

  void _showMatchDialog(Roommate roommate) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withAlpha(160),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (context, _, __) {
        return _MatchDialog(roommate: roommate, onChat: () {
          Navigator.pop(context);
          widget.onOpenMatches();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _index < sampleRoommates.length;

    return AnimatedBackground(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: hasMore ? _buildCardStack() : _buildEmpty(),
          ),
          if (hasMore) _buildActions(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.pink, AppColors.purple],
            ).createShader(bounds),
            child: const Text(
              'Discover',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          if (widget.matchCount > 0)
            GestureDetector(
              onTap: widget.onOpenMatches,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.matchCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.04, duration: 1200.ms, curve: Curves.easeInOut),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildCardStack() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Third card (deepest)
          if (_index + 2 < sampleRoommates.length)
            Transform.translate(
              offset: const Offset(0, 30),
              child: Transform.scale(
                scale: 0.88,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.25,
                    child: RoommateCard(roommate: sampleRoommates[_index + 2]),
                  ),
                ),
              ),
            ),
          // Second card
          if (_index + 1 < sampleRoommates.length)
            Transform.translate(
              offset: const Offset(0, 16),
              child: Transform.scale(
                scale: 0.94,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.5,
                    child: RoommateCard(roommate: sampleRoommates[_index + 1]),
                  ),
                ),
              ),
            ),
          // Top draggable card
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
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: 'Pass',
            icon: Icons.close_rounded,
            color: AppColors.red,
            onTap: () => _handleSwipe(false),
          ),
          ActionButton(
            label: 'Super',
            icon: Icons.star_rounded,
            color: AppColors.yellow,
            onTap: () => _handleSwipe(true),
            large: true,
          ),
          ActionButton(
            label: 'Like',
            icon: Icons.favorite_rounded,
            color: AppColors.green,
            onTap: () => _handleSwipe(true),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.pink, AppColors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withAlpha(80),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Text('🏠', style: TextStyle(fontSize: 48)),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.06, duration: 2000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 28),
          const Text(
            "You've seen everyone!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          const Text(
            'Check back soon for new profiles.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// ─── Draggable card wrapper ──────────────────────────────────────────────────

class _DragCard extends StatefulWidget {
  final Roommate roommate;
  final void Function(bool liked) onSwipe;

  const _DragCard({
    super.key,
    required this.roommate,
    required this.onSwipe,
  });

  @override
  State<_DragCard> createState() => _DragCardState();
}

class _DragCardState extends State<_DragCard> with TickerProviderStateMixin {
  Offset _offset = Offset.zero;


  late AnimationController _snapController;
  late Animation<Offset> _snapAnim;

  late AnimationController _flyController;
  late Animation<Offset> _flyAnim;

  bool _flying = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
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

  void _onPanUpdate(DragUpdateDetails details) {
    if (_flying) return;
    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_flying) return;

    const threshold = 110.0;
    final vel = details.velocity.pixelsPerSecond;

    final isSwipeRight = _offset.dx > threshold || (vel.dx > 600 && _offset.dx > 40);
    final isSwipeLeft = _offset.dx < -threshold || (vel.dx < -600 && _offset.dx < -40);

    if (isSwipeRight) {
      _flyOff(true, vel);
    } else if (isSwipeLeft) {
      _flyOff(false, vel);
    } else {
      _snapBack();
    }
  }

  void _flyOff(bool liked, Offset velPps) {
    _flying = true;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final targetX = liked ? screenW * 1.8 : -screenW * 1.8;
    final targetY = _offset.dy + velPps.dy * 0.1;

    final fromOffset = _offset;
    final toOffset = Offset(targetX, targetY.clamp(-screenH * 0.5, screenH * 0.5));

    _flyAnim = Tween<Offset>(begin: fromOffset, end: toOffset).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeIn),
    );

    _flyAnim.addListener(() {
      setState(() => _offset = _flyAnim.value);
    });

    _flyController.forward().then((_) {
      widget.onSwipe(liked);
    });
  }

  void _snapBack() {
    final fromOffset = _offset;
    _snapAnim = Tween<Offset>(begin: fromOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
    _snapController.reset();
    _snapAnim.addListener(() {
      setState(() => _offset = _snapAnim.value);
    });
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final rotation = (_offset.dx / 400).clamp(-0.35, 0.35);
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
              // LIKE stamp
              if (likeOpacity > 0.05)
                Positioned(
                  top: 50,
                  left: 24,
                  child: Opacity(
                    opacity: likeOpacity.clamp(0.0, 1.0),
                    child: const Stamp(text: 'LIKE', color: AppColors.green),
                  ),
                ),
              // NOPE stamp
              if (nopeOpacity > 0.05)
                Positioned(
                  top: 50,
                  right: 24,
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

// ─── Match dialog ────────────────────────────────────────────────────────────

class _MatchDialog extends StatelessWidget {
  final Roommate roommate;
  final VoidCallback onChat;

  const _MatchDialog({required this.roommate, required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withAlpha(80),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti-like emoji burst
              _ConfettiRow(),
              const SizedBox(height: 16),
              // Avatars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Avatar(emoji: '✨', gradient: const [AppColors.pink, AppColors.purple]),
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      gradient: AppColors.pinkPurpleGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  ),
                  _Avatar(emoji: roommate.emoji, gradient: roommate.gradient),
                ],
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.pink, AppColors.purple],
                ).createShader(bounds),
                child: const Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and ${roommate.name} both liked each other.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: onChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.pink, AppColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Start Chatting',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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

class _Avatar extends StatelessWidget {
  final String emoji;
  final List<Color> gradient;

  const _Avatar({required this.emoji, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
    );
  }
}

class _ConfettiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const emojis = ['🎉', '✨', '🎊', '💫', '⭐'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: emojis
          .asMap()
          .entries
          .map((e) => Text(e.value, style: const TextStyle(fontSize: 22))
              .animate()
              .scale(
                delay: (80 * e.key).ms,
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(delay: (80 * e.key).ms))
          .toList(),
    );
  }
}
