import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.type) {
      case 'Room':      return AppColors.primary;
      case 'Apartment': return AppColors.blue;
      case 'Condo':     return AppColors.teal;
      case 'House':     return AppColors.orange;
      case 'Duplex':    return AppColors.green;
      case 'Studio':    return AppColors.pink;
      default:          return AppColors.primary;
    }
  }

  Color get _accentSoft {
    switch (widget.type) {
      case 'Room':      return AppColors.softPurple;
      case 'Apartment': return AppColors.softBlue;
      case 'Condo':     return const Color(0xFFCCFBF1);
      case 'House':     return AppColors.softOrange;
      case 'Duplex':    return AppColors.softGreen;
      case 'Studio':    return AppColors.softPink;
      default:          return AppColors.softPurple;
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageArea(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypePill(type: widget.type, color: _accent, bg: _accentSoft),
                        const Spacer(),
                        if (widget.availableDate == 'Now')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softGreen,
                              borderRadius: BorderRadius.circular(10),
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
                                Text(
                                  'Available Now',
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.greenDark,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      widget.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: _accent),
                        const SizedBox(width: 3),
                        Text(
                          widget.location,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoTag('\$${widget.rent}/mo', AppColors.green, AppColors.softGreen),
                        _InfoTag(widget.bedsBaths, _accent, _accentSoft),
                        if (widget.availableDate != 'Now')
                          _InfoTag('Avail. ${widget.availableDate}', AppColors.orange, AppColors.softOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(
                delay: (80 * widget.animationIndex).ms, duration: 320.ms)
            .slideY(
                begin: 0.07,
                delay: (80 * widget.animationIndex).ms,
                duration: 320.ms,
                curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: Stack(
        children: [
          // Decorative accent circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _accent.withAlpha(20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _accent.withAlpha(14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SvgPicture.asset(
              'assets/icons/ic_listings.svg',
              width: 52,
              height: 52,
              colorFilter: ColorFilter.mode(
                  _accent.withAlpha(140), BlendMode.srcIn),
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
  final Color bg;

  const _TypePill({required this.type, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        type,
        style: GoogleFonts.dmSans(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;

  const _InfoTag(this.text, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
