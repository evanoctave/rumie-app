import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'circle_button.dart';

/// Bottom-sheet chrome: handle, title row, close button, body.
class AppSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final ScrollController? scrollController;
  final EdgeInsets padding;

  const AppSheet({
    super.key,
    required this.title,
    required this.child,
    this.scrollController,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 32),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppColors.floatingShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: AppColors.lineStrong, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppText.sectionTitle)),
                CircleButton(
                  size: 36,
                  iconAsset: 'assets/icons/ic_close.svg',
                  semanticLabel: 'Close',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: padding.copyWith(bottom: padding.bottom + MediaQuery.viewInsetsOf(context).bottom),
              children: [child],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens [sheet] with the standard draggable sizing.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required Widget Function(ScrollController controller) builder,
  double initialSize = 0.85,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.photoInk.withValues(alpha: 0.45),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, controller) => builder(controller),
    ),
  );
}
