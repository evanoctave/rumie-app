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
      _showMatchDialog(sampleRoommates[_index]);
    }

    if (_index < sampleRoommates.length - 1) {
      setState(() => _index++);
    } else {
      setState(() => _index = sampleRoommates.length);
    }
  }

  void _showMatchDialog(Roommate roommate) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.darkText, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "It's a Match!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You and ${roommate.name} both liked each other.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onOpenMatches();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.darkText,
                    side: const BorderSide(
                      color: AppColors.darkText,
                      width: 3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start chatting',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _index < sampleRoommates.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: 70, left: -40, child: _blob(AppColors.softBlue, 90)),
          Positioned(top: 170, right: -30, child: _triangle(AppColors.yellow)),
          Column(
            children: [
              Expanded(
                child: hasMore ? _buildCardStack() : _buildEmpty(),
              ),
              if (hasMore) _buildActions(),
              const SizedBox(height: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_index + 1 < sampleRoommates.length)
            Transform.translate(
              offset: const Offset(0, 18),
              child: Transform.scale(
                scale: 0.94,
                child: Opacity(
                  opacity: 0.35,
                  child: RoommateCard(
                    roommate: sampleRoommates[_index + 1],
                  ),
                ),
              ),
            ),
          RoommateCard(
            key: ValueKey(_index),
            roommate: sampleRoommates[_index],
            onTap: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: 'Pass',
            icon: Icons.close,
            color: AppColors.pink,
            onTap: () => _next(false),
          ),
          ActionButton(
            label: 'Chat',
            icon: Icons.chat_bubble_outline,
            color: AppColors.blue,
            onTap: widget.onOpenMatches,
          ),
          ActionButton(
            label: 'Like',
            icon: Icons.thumb_up_alt,
            color: AppColors.green,
            onTap: () => _next(true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          "That's everyone for now!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _triangle(Color color) {
    return CustomPaint(
      size: const Size(70, 70),
      painter: _TrianglePainter(color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
