import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/entities/entities.dart';
import '../theme/app_colors.dart';
import 'ui/photo.dart';

/// Deterministic avatar + accent palette for API entities, which carry no
/// artwork of their own. The same id always maps to the same look.
///
/// Presentation-only. Kept out of `lib/domain/` so entities stay plain Dart.
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

  static const _gradients = [
    [Color(0xFF6D4FE0), Color(0xFFC54BA8)],
    [Color(0xFF3A7BE0), Color(0xFF6D4FE0)],
    [Color(0xFFE0557A), Color(0xFFE88A3C)],
    [Color(0xFF1E9A8F), Color(0xFF2FB36A)],
    [Color(0xFFE0813C), Color(0xFFD9A41B)],
  ];

  /// Photos registered by the demo launcher, keyed by entity id. Real data
  /// never populates this; the API has no photo field for groups.
  static final Map<String, String> photoOverrides = {};

  factory AvatarStyle.forId(String id) {
    final h = stableHash(id);
    return AvatarStyle._(
      _assets[h % _assets.length],
      _gradients[(h ~/ _assets.length) % _gradients.length],
    );
  }

  /// Stable color for a trait/tag label.
  static Color traitColor(String label) {
    final colors = [
      AppColors.positive,
      AppColors.accent,
      AppColors.warning,
      AppColors.danger,
    ];
    return colors[stableHash(label.toLowerCase()) % colors.length];
  }

  /// `String.hashCode` is not guaranteed stable across runs; this is.
  static int stableHash(String s) =>
      s.codeUnits.fold(17, (a, c) => (a * 31 + c) & 0x3fffffff);
}

/// Full-bleed artwork for a discovery candidate: the registered photo when
/// one exists, otherwise a gradient with the deterministic avatar.
class CandidateArt extends StatelessWidget {
  final RoommateCandidate candidate;
  const CandidateArt({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final photo = candidate.photoUrl ?? AvatarStyle.photoOverrides[candidate.id];
    final style = AvatarStyle.forId(candidate.id);
    if (photo != null && photo.isNotEmpty) {
      return RumiePhoto(path: photo, fallbackName: candidate.name, tint: style.gradient);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: style.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.25),
        child: FractionallySizedBox(
          widthFactor: 0.58,
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(style.asset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
