import 'package:flutter/material.dart';

import 'trait.dart';

/// A roommate profile shown in the swipe deck.
class Roommate {
  final String name;
  final int age;
  final String emoji;
  final int budget;
  final String location;
  final String bio;

  final List<Trait> traits;

  final List<Color> gradient;

  const Roommate({
    required this.name,
    required this.age,
    required this.emoji,
    required this.budget,
    required this.location,
    required this.bio,
    required this.traits,
    required this.gradient,
  });
}
