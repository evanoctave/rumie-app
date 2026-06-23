import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rumie_icon.dart';

class ActionButton extends StatefulWidget {
  final String label;
  final String svgAsset;
  final Color color;
  final VoidCallback onTap;
  final bool large;

  const ActionButton({
    super.key,
    required this.label,
    required this.svgAsset,
    required this.color,
    required this.onTap,
    this.large = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.86,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? 82.0 : 66.0;
    final iconSize = widget.large ? 30.0 : 24.0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _ctrl.reverse();
      },
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: widget.color.withAlpha(80), width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RumieIcon(
                asset: widget.svgAsset,
                size: iconSize,
                color: widget.color,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
