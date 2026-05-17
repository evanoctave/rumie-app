import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class _ListingCardState extends State<ListingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  // Each type maps to a gradient pair
  static const Map<String, List<Color>> _typeGradients = {
    'Room': [Color(0xFF1CB0F6), Color(0xFF00B8A0)],
    'Apartment': [Color(0xFF1CB0F6), Color(0xFF0284C7)],
    'Condo': [Color(0xFF58CC02), Color(0xFF1CB0F6)],
    'House': [Color(0xFFFF9600), Color(0xFFEA580C)],
    'Duplex': [Color(0xFF00B8A0), Color(0xFF1CB0F6)],
    'Studio': [Color(0xFF58CC02), Color(0xFF00B8A0)],
  };

  List<Color> get _gradient =>
      _typeGradients[widget.type] ?? [AppColors.blue, AppColors.teal];

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) => _pressController.forward(),
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressController,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _gradient.first.withAlpha(20),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageArea(),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _typePill(),
                          const Spacer(),
                          if (widget.availableDate == 'Now')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.softGreen,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.green.withAlpha(80)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Available Now',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            widget.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _infoChip(
                            icon: Icons.attach_money_rounded,
                            text: '\$${widget.rent}/mo',
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 8),
                          _infoChip(
                            icon: Icons.bed_rounded,
                            text: widget.bedsBaths,
                            color: AppColors.blue,
                          ),
                        ],
                      ),
                      if (widget.availableDate != 'Now') ...[
                        const SizedBox(height: 8),
                        _infoChip(
                          icon: Icons.calendar_month_rounded,
                          text: 'Avail. ${widget.availableDate}',
                          color: AppColors.yellow,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: (80 * widget.animationIndex).ms,
              duration: 400.ms,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              delay: (80 * widget.animationIndex).ms,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.home_rounded,
              size: 64,
              color: Colors.white38,
            ),
          ),
          // Bottom fade
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.cardBg],
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

  Widget _typePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _gradient.first.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        widget.type,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
