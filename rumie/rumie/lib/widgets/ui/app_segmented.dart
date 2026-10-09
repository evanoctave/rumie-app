import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';

/// Segmented control with a thumb that slides between equal-width options.
class AppSegmented extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const AppSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final index = options.indexOf(value).clamp(0, options.length - 1);
    final n = options.length;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: AppColors.surfaceSunken,
        shape: AppShapes.shape(AppShapes.input),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / n;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.of(context, AppMotion.slow),
                curve: AppMotion.enter,
                left: index * w,
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: AppColors.surface,
                    shape: AppShapes.shape(AppShapes.input - 4),
                    shadows: AppColors.cardShadow,
                  ),
                ),
              ),
              Row(
                children: [
                  for (final opt in options)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: opt == value,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (opt == value) return;
                            HapticFeedback.selectionClick();
                            onChanged(opt);
                          },
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppMotion.of(context, AppMotion.base),
                              style: AppText.buttonSmall.copyWith(
                                color: opt == value ? AppColors.text : AppColors.textSecondary,
                                fontWeight: opt == value ? FontWeight.w600 : FontWeight.w500,
                              ),
                              child: Text(opt, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
