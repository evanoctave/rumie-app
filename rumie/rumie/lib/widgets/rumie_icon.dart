import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RumieIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const RumieIcon({
    super.key,
    required this.asset,
    this.size = 24,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
