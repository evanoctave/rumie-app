import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'rumie_icon.dart';
import 'ui/app_button.dart';
import 'ui/app_chip.dart';
import 'ui/circle_button.dart';
import 'ui/photo.dart';
import 'ui/pressable.dart';

/// Photo-first discover card. The photo parallaxes against scroll; the
/// name, traits, and actions sit on a scrim at the bottom.
class DiscoverCard extends StatelessWidget {
  final Roommate roommate;
  final VoidCallback onPass;
  final VoidCallback onConnect;
  final VoidCallback onTap;
  final bool heroEnabled;

  const DiscoverCard({
    super.key,
    required this.roommate,
    required this.onPass,
    required this.onConnect,
    required this.onTap,
    this.heroEnabled = true,
  });

  static String heroTag(Roommate r) => 'photo-${r.name}';

  @override
  Widget build(BuildContext context) {
    final r = roommate;
    Widget photo = ParallaxPhoto(path: r.avatarAsset, name: r.name, tint: r.gradient);
    if (heroEnabled) photo = Hero(tag: heroTag(r), child: photo);

    return Pressable(
      onTap: onTap,
      pressedScale: 0.985,
      haptic: false,
      semanticLabel: '${r.name}, ${r.age}, ${r.location}',
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
                photo,
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
                Positioned(
                  top: 16,
                  left: 16,
                  child: AppChip(
                    label: '\$${r.budget}/mo',
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
                            TextSpan(text: r.name, style: AppText.cardName.copyWith(color: AppColors.photoText)),
                            TextSpan(
                              text: '  ${r.age}',
                              style: AppText.cardName.copyWith(
                                color: AppColors.photoText.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
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
                              r.location,
                              style: AppText.secondary.copyWith(color: AppColors.photoText.withValues(alpha: 0.85)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in r.traits.take(3))
                            AppChip(label: t.title, style: AppChipStyle.onPhoto, dense: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleButton(
                            size: 54,
                            iconAsset: 'assets/icons/ic_close.svg',
                            style: CircleButtonStyle.onPhoto,
                            semanticLabel: 'Pass on ${r.name}',
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

/// Photo that drifts against the nearest scrollable. Outside a scrollable
/// (for example mid Hero flight) it renders as a plain photo.
class ParallaxPhoto extends StatefulWidget {
  final String path;
  final String name;
  final List<Color>? tint;

  const ParallaxPhoto({super.key, required this.path, required this.name, this.tint});

  @override
  State<ParallaxPhoto> createState() => _ParallaxPhotoState();
}

class _ParallaxPhotoState extends State<ParallaxPhoto> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scrollable = Scrollable.maybeOf(context);
    final photo = RumiePhoto(key: _imageKey, path: widget.path, fallbackName: widget.name, tint: widget.tint);
    if (scrollable == null || MediaQuery.disableAnimationsOf(context)) return photo;
    return Flow(
      clipBehavior: Clip.hardEdge,
      delegate: _ParallaxDelegate(scrollable: scrollable, itemContext: context, imageKey: _imageKey),
      children: [photo],
    );
  }
}

class _ParallaxDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final GlobalKey imageKey;

  static const double _extra = 0.22;

  _ParallaxDelegate({required this.scrollable, required this.itemContext, required this.imageKey})
      : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tightFor(width: constraints.maxWidth, height: constraints.maxHeight * (1 + _extra));

  @override
  void paintChildren(FlowPaintingContext context) {
    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    final item = itemContext.findRenderObject() as RenderBox?;
    final image = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null || item == null || image == null || !item.attached) {
      context.paintChild(0);
      return;
    }
    final itemCenter = item.localToGlobal(item.size.center(Offset.zero), ancestor: viewport);
    final frac = (itemCenter.dy / viewport.size.height).clamp(0.0, 1.0);
    final overflow = image.size.height - context.size.height;
    final dy = -overflow * (1 - frac);
    context.paintChild(0, transform: Matrix4.translationValues(0, dy, 0));
  }

  @override
  bool shouldRepaint(_ParallaxDelegate old) =>
      old.scrollable != scrollable || old.itemContext != itemContext || old.imageKey != imageKey;
}
