import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Deterministic avatar + accent palette for API entities, which carry no
/// artwork of their own. The same id always maps to the same look.
///
/// Presentation-only — kept out of `lib/domain/` so entities stay plain Dart.
class AvatarStyle {
  final String asset;
  final List<Color> gradient;

  const AvatarStyle._(this.asset, this.gradient);

  static const _assets = [
    'assets/icons/av_alex.svg',
    'assets/icons/av_aria.svg',
    'assets/icons/av_devon.svg',
    'assets/icons/av_jordan.svg',
    'assets/icons/av_maya.svg',
    'assets/icons/av_priya.svg',
    'assets/icons/av_riley.svg',
    'assets/icons/av_sam.svg',
  ];

  // Same pairs the original sample cards used.
  static const _gradients = [
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFF3B82F6), Color(0xFF7C3AED)],
    [Color(0xFFEC4899), Color(0xFFF97316)],
    [Color(0xFF14B8A6), Color(0xFF10B981)],
    [Color(0xFFF97316), Color(0xFFF59E0B)],
  ];

  static const _traitColors = [
    AppColors.green,
    AppColors.primary,
    AppColors.pink,
    AppColors.yellow,
    AppColors.blue,
    AppColors.orange,
    AppColors.teal,
  ];

  factory AvatarStyle.forId(String id) {
    final h = stableHash(id);
    return AvatarStyle._(
      _assets[h % _assets.length],
      _gradients[(h ~/ _assets.length) % _gradients.length],
    );
  }

  /// Stable color for a trait/tag label.
  static Color traitColor(String label) =>
      _traitColors[stableHash(label.toLowerCase()) % _traitColors.length];

  /// `String.hashCode` is not guaranteed stable across runs; this is.
  static int stableHash(String s) =>
      s.codeUnits.fold(17, (a, c) => (a * 31 + c) & 0x3fffffff);
}

/// Renders a profile photo from a local path, a network URL, or the bundled
/// placeholder avatar.
class ProfilePhoto extends StatelessWidget {
  final String path;
  final Widget placeholder;
  final BoxFit fit;

  const ProfilePhoto({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  static bool isRemote(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return placeholder;
    if (isRemote(path)) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return Image.file(File(path), fit: fit, errorBuilder: (_, _, _) => placeholder);
  }
}
