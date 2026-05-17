import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../models/trait.dart';

const List<Roommate> sampleRoommates = [
  Roommate(
    name: 'Maya',
    age: 24,
    avatarAsset: 'assets/icons/av_maya.svg',
    budget: 1200,
    location: 'Mission District',
    bio: 'Grad student, loves plants and quiet evenings. Looking for a chill space to call home.',
    traits: [
      Trait(title: 'Very tidy', color: Color(0xFF22C55E)),
      Trait(title: 'Night owl', color: Color(0xFF4ADE80)),
      Trait(title: 'Has a cat', color: Color(0xFF16A34A)),
      Trait(title: 'Studious', color: Color(0xFF86EFAC)),
    ],
    gradient: [Color(0xFF22C55E), Color(0xFF16A34A)],
  ),
  Roommate(
    name: 'Jordan',
    age: 27,
    avatarAsset: 'assets/icons/av_jordan.svg',
    budget: 1500,
    location: 'SoMa',
    bio: 'Software engineer. Big fan of weekend coffee runs and weekday silence.',
    traits: [
      Trait(title: 'Works from home', color: Color(0xFF4ADE80)),
      Trait(title: 'Early bird', color: Color(0xFFEAB308)),
      Trait(title: 'Non-smoker', color: Color(0xFF22C55E)),
      Trait(title: 'Gamer', color: Color(0xFF86EFAC)),
    ],
    gradient: [Color(0xFF22C55E), Color(0xFF15803D)],
  ),
  Roommate(
    name: 'Aria',
    age: 22,
    avatarAsset: 'assets/icons/av_aria.svg',
    budget: 900,
    location: 'Oakland',
    bio: 'Art student. I bake a lot. Sometimes paint at 2am. Sorry not sorry.',
    traits: [
      Trait(title: 'Creative', color: Color(0xFFEAB308)),
      Trait(title: 'Loves cooking', color: Color(0xFF22C55E)),
      Trait(title: 'Night owl', color: Color(0xFF4ADE80)),
      Trait(title: 'Vegetarian', color: Color(0xFF16A34A)),
    ],
    gradient: [Color(0xFF16A34A), Color(0xFF166534)],
  ),
  Roommate(
    name: 'Sam',
    age: 29,
    avatarAsset: 'assets/icons/av_sam.svg',
    budget: 1800,
    location: 'Berkeley',
    bio: 'Yoga teacher, dog parent, plant collector. Looking for someone calm and respectful.',
    traits: [
      Trait(title: 'Zen vibes', color: Color(0xFF4ADE80)),
      Trait(title: 'Has a dog', color: Color(0xFFEAB308)),
      Trait(title: 'Early bird', color: Color(0xFF22C55E)),
      Trait(title: 'Very tidy', color: Color(0xFF86EFAC)),
    ],
    gradient: [Color(0xFF22C55E), Color(0xFF16A34A)],
  ),
  Roommate(
    name: 'Devon',
    age: 25,
    avatarAsset: 'assets/icons/av_devon.svg',
    budget: 1100,
    location: 'Outer Sunset',
    bio: 'Musician + barista. Headphones are my love language. Quiet apartment, loud songs.',
    traits: [
      Trait(title: 'Music lover', color: Color(0xFF4ADE80)),
      Trait(title: 'Night owl', color: Color(0xFF22C55E)),
      Trait(title: 'Loves cooking', color: Color(0xFFEAB308)),
      Trait(title: 'Non-smoker', color: Color(0xFF86EFAC)),
    ],
    gradient: [Color(0xFF16A34A), Color(0xFF166534)],
  ),
];
