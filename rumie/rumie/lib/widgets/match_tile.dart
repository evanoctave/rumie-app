import 'package:flutter/material.dart';

import '../domain/entities/entities.dart';
import '../screens/chat_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'avatar_style.dart';
import 'rumie_icon.dart';
import 'ui/photo.dart';
import 'ui/pressable.dart';

/// Row in the matches list. Avatar flies into the chat header on tap.
class MatchTile extends StatelessWidget {
  final MatchSummary match;
  final VoidCallback? onTap;

  const MatchTile({super.key, required this.match, this.onTap});

  static String heroTag(MatchSummary m) => 'avatar-${m.id}';

  @override
  Widget build(BuildContext context) {
    final style = AvatarStyle.forId(match.id);
    return Pressable(
      onTap: onTap ?? () => Navigator.of(context).push(ChatScreen.route(match)),
      pressedScale: 0.98,
      semanticLabel: 'Chat: ${match.title}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
          shadows: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Avatar(path: style.asset, name: match.title, size: 58, tint: style.gradient, heroTag: heroTag(match)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.title, style: AppText.tileTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(match.subtitle, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
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
