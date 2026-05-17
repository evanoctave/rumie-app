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
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? 84.0 : 70.0;
    final iconSize = widget.large ? 28.0 : 24.0;

    return GestureDetector(
      onTapDown: (_) { HapticFeedback.mediumImpact(); _ctrl.reverse(); },
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.color.withAlpha(100), width: 1.5),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
