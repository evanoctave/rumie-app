import 'package:flutter/material.dart';

import 'trait.dart';

class Roommate {
  final String name;
  final int age;
  final String avatarAsset; // path to SVG asset (replaces emoji)
  final int budget;
  final String location;
  final String bio;
  final List<Trait> traits;
  final List<Color> gradient;

  const Roommate({
    required this.name,
    required this.age,
    required this.avatarAsset,
    required this.budget,
    required this.location,
    required this.bio,
    required this.traits,
    required this.gradient,
  });
}
