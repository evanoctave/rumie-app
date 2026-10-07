import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';

/// Renders a profile photo from an asset path, a file path, or an SVG.
/// Falls back to a tinted initial so a missing file never shows a broken
/// image.
class RumiePhoto extends StatelessWidget {
  final String path;
  final String fallbackName;
  final List<Color>? tint;
  final BoxFit fit;

  const RumiePhoto({
    super.key,
    required this.path,
    required this.fallbackName,
    this.tint,
    this.fit = BoxFit.cover,
  });

  bool get _isFile => path.startsWith('/');
  bool get _isSvg => path.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _Fallback(name: fallbackName, tint: tint);
    if (_isSvg) {
      return ColoredBox(
        color: (tint?.first ?? AppColors.accent).withValues(alpha: 0.18),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: SvgPicture.asset(path, fit: BoxFit.contain),
          ),
        ),
      );
    }
    if (_isFile) {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (_, _, _) => _Fallback(name: fallbackName, tint: tint),
      );
    }
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, _, _) => _Fallback(name: fallbackName, tint: tint),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String name;
  final List<Color>? tint;
  const _Fallback({required this.name, this.tint});

  @override
  Widget build(BuildContext context) {
    final colors = tint ?? [AppColors.accent, AppColors.accentDeep];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, c) => Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppText.hero.copyWith(
              fontSize: (c.maxWidth * 0.42).clamp(16, 120),
              color: AppColors.photoText.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square superellipse avatar.
class Avatar extends StatelessWidget {
  final String path;
  final String name;
  final double size;
  final List<Color>? tint;
  final String? heroTag;

  const Avatar({
    super.key,
    required this.path,
    required this.name,
    this.size = 48,
    this.tint,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.32;
    Widget child = ClipRSuperellipse(
      borderRadius: AppShapes.radius(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: RumiePhoto(path: path, fallbackName: name, tint: tint),
      ),
    );
    if (heroTag != null) child = Hero(tag: heroTag!, child: child);
    return child;
  }
}
