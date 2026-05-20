import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/roommate.dart';
import '../screens/chat_screen.dart';
import '../theme/app_colors.dart';

class MatchTile extends StatefulWidget {
  final Roommate roommate;
  final int animationIndex;

  const MatchTile({super.key, required this.roommate, this.animationIndex = 0});

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openChat() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) =>
            ChatScreen(roommate: widget.roommate),
        transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.roommate.gradient;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _ctrl.reverse();
      },
      onTapUp: (_) {
        _ctrl.forward();
        _openChat();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradient.first.withAlpha(80),
                      gradient.last.withAlpha(40),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gradient.first.withAlpha(80), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      widget.roommate.avatarAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.roommate.name}, ${widget.roommate.age}',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.roommate.location} · \$${widget.roommate.budget}/mo',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(8),
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
                            'Matched',
                            style: GoogleFonts.dmSans(
                              color: AppColors.greenDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Chat button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.buttonShadow,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_chat.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (60 * widget.animationIndex).ms, duration: 300.ms)
        .slideX(
          begin: 0.08,
          end: 0,
          delay: (60 * widget.animationIndex).ms,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
