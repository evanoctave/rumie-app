import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import 'pressable.dart';

/// Slides a small card in from the top. Used for "You connected with…".
/// Tapping the action dismisses and fires [onAction]; otherwise it auto
/// dismisses after [hold].
void showTopToast(
  BuildContext context, {
  required Widget leading,
  required String title,
  String? subtitle,
  String? actionLabel,
  VoidCallback? onAction,
  Duration hold = const Duration(milliseconds: 2800),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  final controller = _ToastController();
  entry = OverlayEntry(
    builder: (ctx) => _Toast(
      controller: controller,
      leading: leading,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      hold: hold,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _ToastController {
  VoidCallback? dismiss;
}

class _Toast extends StatefulWidget {
  final _ToastController controller;
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration hold;
  final VoidCallback onDone;

  const _Toast({
    required this.controller,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.hold,
    required this.onDone,
  });

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: AppMotion.slow, reverseDuration: AppMotion.base);
    widget.controller.dismiss = _dismiss;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _anim.duration = AppMotion.of(context, AppMotion.slow);
      _anim.reverseDuration = AppMotion.of(context, AppMotion.base);
      _anim.forward();
      _timer = Timer(widget.hold, _dismiss);
    });
  }

  Future<void> _dismiss() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    await _anim.reverse();
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _anim, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
    final top = MediaQuery.paddingOf(context).top + 8;
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -1.2), end: Offset.zero).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if ((d.primaryVelocity ?? 0) < -100) _dismiss();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: AppShapes.shape(AppShapes.tile),
                  shadows: AppColors.floatingShadow,
                ),
                child: Row(
                  children: [
                    widget.leading,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title, style: AppText.tileTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(widget.subtitle!, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 10),
                      Pressable(
                        onTap: () {
                          _dismiss();
                          widget.onAction?.call();
                        },
                        pressedScale: 0.94,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: AppText.buttonSmall.copyWith(color: AppColors.onAccent),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
