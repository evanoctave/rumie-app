import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_motion.dart';

/// Tap target that scales down on press and settles back on release.
/// Every custom tappable surface in the app goes through this so feedback
/// feels identical. `onTap: null` renders inert.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool haptic;
  final String? semanticLabel;
  final bool selected;
  final HitTestBehavior behavior;

  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.haptic = true,
    this.semanticLabel,
    this.selected = false,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down == down) return;
    setState(() => _down = down);
  }

  void _tap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: enabled ? _tap : null,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down ? widget.pressedScale : 1,
          duration: AppMotion.of(
            context,
            _down ? const Duration(milliseconds: 90) : AppMotion.base,
          ),
          curve: AppMotion.exit,
          child: widget.child,
        ),
      ),
    );
  }
}
