import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../screens/chat_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'rumie_icon.dart';
import 'ui/photo.dart';
import 'ui/pressable.dart';

/// Row in the matches list. Avatar flies into the chat header on tap.
class MatchTile extends StatelessWidget {
  final Roommate roommate;
  final VoidCallback? onTap;

  const MatchTile({super.key, required this.roommate, this.onTap});

  static String heroTag(Roommate r) => 'avatar-${r.name}';

  @override
  Widget build(BuildContext context) {
    final r = roommate;
    return Pressable(
      onTap: onTap ?? () => Navigator.of(context).push(ChatScreen.route(r)),
      pressedScale: 0.98,
      semanticLabel: 'Chat with ${r.name}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
          shadows: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Avatar(path: r.avatarAsset, name: r.name, size: 58, tint: r.gradient, heroTag: heroTag(r)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: AppText.tileTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${r.location}  ·  \$${r.budget}/mo',
                    style: AppText.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
              child: Center(
                child: RumieIcon(asset: 'assets/icons/ic_chat.svg', size: 18, color: AppColors.accentDeep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
