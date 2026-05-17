import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? 90.0 : 76.0;
    final iconSize = widget.large ? 32.0 : 26.0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _controller.reverse();
      },
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(20),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: widget.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(50),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RumieIcon(asset: widget.svgAsset, size: iconSize, color: widget.color),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
