import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class ListingCard extends StatefulWidget {
  final String title;
  final String type;
  final String location;
  final int rent;
  final String bedsBaths;
  final String availableDate;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.title,
    required this.type,
    required this.location,
    required this.rent,
    required this.bedsBaths,
    required this.availableDate,
    this.animationIndex = 0,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100),
        lowerBound: 0.97, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // Clean single-color accent per type
  Color get _accent {
    switch (widget.type) {
      case 'Room':      return AppColors.primary;
      case 'Apartment': return AppColors.primary;
      case 'Condo':     return AppColors.teal;
      case 'House':     return AppColors.orange;
      case 'Duplex':    return AppColors.teal;
      case 'Studio':    return AppColors.green;
      default:          return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageArea(),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypePill(type: widget.type, color: _accent),
                        const Spacer(),
                        if (widget.availableDate == 'Now')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.softGreen,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.green.withAlpha(80)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Available Now',
                                  style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ic_location.svg',
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.location,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _InfoTag('\$${widget.rent}/mo', AppColors.green),
                        _InfoTag(widget.bedsBaths, AppColors.primary),
                        if (widget.availableDate != 'Now')
                          _InfoTag('Avail. ${widget.availableDate}', AppColors.yellow),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (70 * widget.animationIndex).ms, duration: 300.ms)
            .slideY(begin: 0.06, delay: (70 * widget.animationIndex).ms, duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: _accent.withAlpha(30),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/icons/ic_listings.svg',
              width: 48,
              height: 48,
              colorFilter: ColorFilter.mode(_accent.withAlpha(100), BlendMode.srcIn),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.cardBg.withAlpha(220)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;
  final Color color;
  const _TypePill({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoTag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
