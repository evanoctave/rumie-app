import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/utils/profile_styles.dart';

/// Avatar that renders SVG or raster assets, falling back to an
/// initial-on-gradient when no asset is given.
class RumieAvatar extends StatelessWidget {
  final String asset;
  final String name;
  final double size;

  /// Used to pick a stable fallback gradient.
  final String id;

  const RumieAvatar({
    super.key,
    this.asset = '',
    required this.name,
    this.size = 48,
    this.id = '',
  });

  @override
  Widget build(BuildContext context) {
    final gradient = ProfileStyles.gradientFor(id.isEmpty ? name : id);

    Widget inner;
    if (asset.endsWith('.svg')) {
      inner = SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (asset.isNotEmpty) {
      inner = Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initial(gradient),
      );
    } else {
      inner = _initial(gradient);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: inner,
    );
  }

  Widget _initial(List<Color> gradient) {
    return Center(
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
