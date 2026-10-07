import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import '../rumie_icon.dart';
import 'pressable.dart';

/// Grouped settings surface: rows separated by hairlines inside one tile.
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title!, style: AppText.label),
          ),
        ],
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.line),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({super.key, required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null) Text(subtitle!, style: AppText.caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class NavRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  const NavRow({super.key, required this.label, this.value, this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.99,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: danger ? AppColors.danger : AppColors.text,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value!, style: AppText.secondary),
              const SizedBox(width: 6),
            ],
            if (!danger)
              RumieIcon(asset: 'assets/icons/ic_chevron.svg', size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
