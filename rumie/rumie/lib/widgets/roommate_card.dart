import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import 'stamp.dart';
import 'trait_chip.dart';

/// Draggable roommate profile card. Drag past 30% of screen width to
/// commit a swipe; release before that to spring back.
///
/// The header includes photo-carousel dots ("now ○○○○○" in the sketch)
/// so the user can see how many photos exist; the current implementation
/// uses a placeholder gradient + emoji until real photos are wired up.
class RoommateCard extends StatefulWidget {
  final Roommate roommate;
  final void Function(bool liked) onSwipe;
  final bool isBack;

  const RoommateCard({
    super.key,
    required this.roommate,
    required this.onSwipe,
    this.isBack = false,
  });

  @override
  State<RoommateCard> createState() => _RoommateCardState();
}

class _RoommateCardState extends State<RoommateCard>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late final AnimationController _controller;
  Animation<Offset>? _animation;
  bool _swipingOut = false;

  /// Placeholder: pretend each roommate has 4 photos.
  static const int _photoCount = 4;
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) setState(() => _offset = _animation!.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (widget.isBack || _swipingOut) return;
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isBack || _swipingOut) return;
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails _) {
    if (widget.isBack || _swipingOut) return;
    final width = MediaQuery.of(context).size.width;
    if (_offset.dx.abs() > width * 0.3) {
      _swipingOut = true;
      final liked = _offset.dx > 0;
      _animation = Tween<Offset>(
        begin: _offset,
        end: Offset(liked ? width * 1.5 : -width * 1.5, _offset.dy),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0).then((_) => widget.onSwipe(liked));
    } else {
      _animation = Tween<Offset>(begin: _offset, end: Offset.zero)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  /// Tap left third of the photo area to go back, right two-thirds to advance.
  /// Matches the photo-carousel pattern from the sketch.
  void _tapPhoto(TapUpDetails details, double cardWidth) {
    if (widget.isBack) return;
    final isLeft = details.localPosition.dx < cardWidth * 0.33;
    setState(() {
      if (isLeft) {
        _photoIndex = (_photoIndex - 1).clamp(0, _photoCount - 1);
      } else {
        _photoIndex = (_photoIndex + 1).clamp(0, _photoCount - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final angle = (_offset.dx / width) * 0.3;
    final likeOpacity = (_offset.dx / 100).clamp(0.0, 1.0);
    final nopeOpacity = (-_offset.dx / 100).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: _buildCardContent(likeOpacity, nopeOpacity),
        ),
      ),
    );
  }

  Widget _buildCardContent(double likeOpacity, double nopeOpacity) {
    final r = widget.roommate;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: r.gradient[0].withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  return GestureDetector(
                    onTapUp: (d) => _tapPhoto(d, constraints.maxWidth),
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: r.gradient,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(r.emoji,
                                style: const TextStyle(fontSize: 110)),
                          ),
                          // Photo carousel dots (the "now ○○○○○" from the sketch)
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              children: List.generate(_photoCount, (i) {
                                return Expanded(
                                  child: Container(
                                    height: 4,
                                    margin: EdgeInsets.only(
                                        right: i == _photoCount - 1 ? 0 : 4),
                                    decoration: BoxDecoration(
                                      color: i == _photoIndex
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${r.age}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: AppColors.gray,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$${r.budget}/mo',
                              style: const TextStyle(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            r.location,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.gray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        r.bio,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: r.traits
                            .map((t) => TraitChip(trait: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Opacity(
                opacity: likeOpacity,
                child: Transform.rotate(
                  angle: -0.3,
                  child: const Stamp(text: 'MATCH! 💜', color: AppColors.purple),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Opacity(
                opacity: nopeOpacity,
                child: Transform.rotate(
                  angle: 0.3,
                  child: const Stamp(text: 'PASS', color: AppColors.pink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
