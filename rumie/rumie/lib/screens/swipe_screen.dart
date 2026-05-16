import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/roommate_card.dart';

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

  void _next(bool liked) {
    if (liked && _index < sampleRoommates.length) {
      widget.onMatch(sampleRoommates[_index]);
      _showMatchSnack(sampleRoommates[_index]);
    }
    setState(() => _index++);
  }

  void _showMatchSnack(Roommate r) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Text(r.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "It's a match with ${r.name}! 💜",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _index < sampleRoommates.length;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: hasMore ? _buildCardStack() : _buildEmpty()),
          if (hasMore) _buildActions(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('🏡', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (rect) =>
                AppColors.brandGradient.createShader(rect),
            child: const Text(
              'Roomie',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Spacer(),
          // Matches access: heart icon with badge, top-right of the header.
          GestureDetector(
            onTap: widget.onOpenMatches,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('💜', style: TextStyle(fontSize: 20)),
                ),
                if (widget.matchCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '${widget.matchCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_index + 1 < sampleRoommates.length)
            Transform.scale(
              scale: 0.94,
              child: Transform.translate(
                offset: const Offset(0, 16),
                child: RoommateCard(
                  roommate: sampleRoommates[_index + 1],
                  isBack: true,
                  onSwipe: (_) {},
                ),
              ),
            ),
          RoommateCard(
            key: ValueKey(_index),
            roommate: sampleRoommates[_index],
            onSwipe: _next,
          ),
        ],
      ),
    );
  }

  /// Two action buttons matching the sketch: ✕ (pass) on the left,
  /// ✓ (like) on the right.
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: '✕',
            size: 68,
            background: Colors.white,
            foreground: AppColors.pink,
            onTap: () => _next(false),
          ),
          ActionButton(
            label: '✓',
            size: 68,
            background: AppColors.purple,
            foreground: Colors.white,
            onTap: () => _next(true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌸', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              "That's everyone for now!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back soon for more potential\nroommates near you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: AppColors.gray, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _index = 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start over',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
