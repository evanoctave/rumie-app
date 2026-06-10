import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Presentation helpers that keep domain entities free of Flutter types.
class ProfileStyles {
  ProfileStyles._();

  static const List<List<Color>> _gradients = [
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFF3B82F6), Color(0xFF7C3AED)],
    [Color(0xFFEC4899), Color(0xFFF97316)],
    [Color(0xFF14B8A6), Color(0xFF10B981)],
    [Color(0xFFF97316), Color(0xFFF59E0B)],
    [Color(0xFF10B981), Color(0xFF3B82F6)],
  ];

  /// Stable gradient per entity id, used for photo placeholders and avatars.
  static List<Color> gradientFor(String id) =>
      _gradients[id.hashCode.abs() % _gradients.length];

  static const Map<String, Color> _tagColors = {
    'very tidy': AppColors.green,
    'clean': AppColors.green,
    'night owl': AppColors.primary,
    'early bird': AppColors.yellow,
    'quiet': AppColors.blue,
    'social': AppColors.pink,
    'studious': AppColors.yellow,
    'creative': AppColors.pink,
    'gamer': AppColors.primary,
    'fitness': AppColors.teal,
    'cooking': AppColors.orange,
    'music': AppColors.orange,
    'pets': AppColors.teal,
    'non-smoker': AppColors.green,
    'vegetarian': AppColors.green,
  };

  /// Stable chip color per lifestyle tag.
  static Color tagColor(String tag) {
    final key = tag.toLowerCase();
    for (final entry in _tagColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    const fallback = [
      AppColors.primary,
      AppColors.blue,
      AppColors.teal,
      AppColors.pink,
      AppColors.orange,
    ];
    return fallback[tag.hashCode.abs() % fallback.length];
  }
}
