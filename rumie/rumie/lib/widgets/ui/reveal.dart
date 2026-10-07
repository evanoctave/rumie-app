import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

/// Fade + rise entrance. Pass [index] to stagger siblings; the delay is
/// capped so long lists never feel slow. Respects reduced motion.
class Reveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration stagger;
  final double offsetY;
  final double scaleFrom;

  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 55),
    this.offsetY = 20,
    this.scaleFrom = 1,
  });

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  static const int _maxSteps = 7;

  late final AnimationController _controller;
  Animation<double>? _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_t != null) return;
    final delay = widget.stagger * widget.index.clamp(0, _maxSteps);
    final total = AppMotion.reveal + delay;
    final begin = total.inMilliseconds == 0 ? 0.0 : delay.inMilliseconds / total.inMilliseconds;
    _controller.duration = AppMotion.of(context, total);
    _t = CurvedAnimation(parent: _controller, curve: Interval(begin, 1, curve: AppMotion.enter));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t!;
    return AnimatedBuilder(
      animation: t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - t.value)),
          child: widget.scaleFrom == 1
              ? child
              : Transform.scale(scale: widget.scaleFrom + (1 - widget.scaleFrom) * t.value, child: child),
        ),
      ),
    );
  }
}
