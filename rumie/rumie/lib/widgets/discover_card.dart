import 'package:flutter/material.dart';

import '../domain/entities/entities.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'avatar_style.dart';
import 'rumie_icon.dart';
import 'ui/app_button.dart';
import 'ui/app_chip.dart';
import 'ui/circle_button.dart';
import 'ui/pressable.dart';

/// Photo-first discover card. The art parallaxes against scroll; the name,
/// tags, and actions sit on a scrim at the bottom.
class DiscoverCard extends StatelessWidget {
  final RoommateCandidate candidate;
  final VoidCallback onPass;
  final VoidCallback onConnect;
  final VoidCallback onTap;
  final bool heroEnabled;

  const DiscoverCard({
    super.key,
    required this.candidate,
    required this.onPass,
    required this.onConnect,
    required this.onTap,
    this.heroEnabled = true,
  });

  static String heroTag(RoommateCandidate c) => 'photo-${c.id}';

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    Widget art = ParallaxLayer(child: CandidateArt(candidate: c));
    if (heroEnabled) art = Hero(tag: heroTag(c), child: art);

    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      haptic: false,
      semanticLabel: '${c.headline}, ${c.location}',
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: AppShapes.shape(AppShapes.card),
          shadows: AppColors.cardShadow,
        ),
        child: ClipRSuperellipse(
          borderRadius: AppShapes.radius(AppShapes.card),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                art,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.photoInk.withValues(alpha: 0),
                          AppColors.photoInk.withValues(alpha: 0.55),
                          AppColors.photoInk.withValues(alpha: 0.82),
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                ),
                if (c.budget != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: AppChip(
                      label: '\$${c.budget}/mo',
                      style: AppChipStyle.onPhoto,
                      leading: const RumieIcon(asset: 'assets/icons/ic_money.svg', size: 14, color: AppColors.photoText),
                    ),
                  ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: c.name, style: AppText.cardName.copyWith(color: AppColors.photoText)),
                            if (c.ageLabel.isNotEmpty)
                              TextSpan(
                                text: '  ${c.ageLabel}',
                                style: AppText.cardName.copyWith(
                                  color: AppColors.photoText.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          RumieIcon(asset: 'assets/icons/ic_location.svg', size: 14, color: AppColors.photoText.withValues(alpha: 0.85)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              c.location,
                              style: AppText.secondary.copyWith(color: AppColors.photoText.withValues(alpha: 0.85)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (c.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final t in c.tags.take(3))
                              AppChip(label: t, style: AppChipStyle.onPhoto, dense: true),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleButton(
                            size: 54,
                            iconAsset: 'assets/icons/ic_close.svg',
                            style: CircleButtonStyle.onPhoto,
                            semanticLabel: 'Pass on ${c.name}',
                            onTap: onPass,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: 'Connect',
                              iconAsset: 'assets/icons/ic_like.svg',
                              size: AppButtonSize.large,
                              onTap: onConnect,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drifts its child against the nearest scrollable. Outside a scrollable
/// (for example mid Hero flight) it renders the child as is.
class ParallaxLayer extends StatefulWidget {
  final Widget child;
  const ParallaxLayer({super.key, required this.child});

  @override
  State<ParallaxLayer> createState() => _ParallaxLayerState();
}

class _ParallaxLayerState extends State<ParallaxLayer> {
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    if (scrollable == null || MediaQuery.disableAnimationsOf(context)) return child;
    return Flow(
      clipBehavior: Clip.hardEdge,
      delegate: _ParallaxDelegate(scrollable: scrollable, itemContext: context, childKey: _childKey),
      children: [child],
    );
  }
}

class _ParallaxDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final GlobalKey childKey;

  static const double _extra = 0.22;

  _ParallaxDelegate({required this.scrollable, required this.itemContext, required this.childKey})
      : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tightFor(width: constraints.maxWidth, height: constraints.maxHeight * (1 + _extra));

  @override
  void paintChildren(FlowPaintingContext context) {
    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    final item = itemContext.findRenderObject() as RenderBox?;
    final child = childKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null || item == null || child == null || !item.attached) {
      context.paintChild(0);
      return;
    }
    final itemCenter = item.localToGlobal(item.size.center(Offset.zero), ancestor: viewport);
    final frac = (itemCenter.dy / viewport.size.height).clamp(0.0, 1.0);
    final overflow = child.size.height - context.size.height;
    final dy = -overflow * (1 - frac);
    context.paintChild(0, transform: Matrix4.translationValues(0, dy, 0));
  }

  @override
  bool shouldRepaint(_ParallaxDelegate old) =>
      old.scrollable != scrollable || old.itemContext != itemContext || old.childKey != childKey;
}
