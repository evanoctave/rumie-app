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
      Trait(title: 'Very tidy', color: Color(0xFF1CB0F6)),
      Trait(title: 'Night owl', color: Color(0xFF0891B2)),
      Trait(title: 'Has a cat', color: Color(0xFF58CC02)),
      Trait(title: 'Studious', color: Color(0xFFFF9600)),
    ],
    gradient: [Color(0xFF00B8A0), Color(0xFF1CB0F6)],
  ),
  Roommate(
    name: 'Jordan',
    age: 27,
    avatarAsset: 'assets/icons/av_jordan.svg',
    budget: 1500,
    location: 'SoMa',
    bio: 'Software engineer. Big fan of weekend coffee runs and weekday silence.',
    traits: [
      Trait(title: 'Works from home', color: Color(0xFF1CB0F6)),
      Trait(title: 'Early bird', color: Color(0xFFFFC800)),
      Trait(title: 'Non-smoker', color: Color(0xFF58CC02)),
      Trait(title: 'Gamer', color: Color(0xFF0891B2)),
    ],
    gradient: [Color(0xFF1CB0F6), Color(0xFF0284C7)],
  ),
  Roommate(
    name: 'Aria',
    age: 22,
    avatarAsset: 'assets/icons/av_aria.svg',
    budget: 900,
    location: 'Oakland',
    bio: 'Art student. I bake a lot. Sometimes paint at 2am. Sorry not sorry.',
    traits: [
      Trait(title: 'Creative', color: Color(0xFFFF9600)),
      Trait(title: 'Loves cooking', color: Color(0xFFFF6B35)),
      Trait(title: 'Night owl', color: Color(0xFF0891B2)),
      Trait(title: 'Vegetarian', color: Color(0xFF58CC02)),
    ],
    gradient: [Color(0xFFFF9600), Color(0xFFEA580C)],
  ),
  Roommate(
    name: 'Sam',
    age: 29,
    avatarAsset: 'assets/icons/av_sam.svg',
    budget: 1800,
    location: 'Berkeley',
    bio: 'Yoga teacher, dog parent, plant collector. Looking for someone calm and respectful.',
    traits: [
      Trait(title: 'Zen vibes', color: Color(0xFF1CB0F6)),
      Trait(title: 'Has a dog', color: Color(0xFFFFC800)),
      Trait(title: 'Early bird', color: Color(0xFF58CC02)),
      Trait(title: 'Very tidy', color: Color(0xFF00B8A0)),
    ],
    gradient: [Color(0xFF58CC02), Color(0xFF15803D)],
  ),
  Roommate(
    name: 'Devon',
    age: 25,
    avatarAsset: 'assets/icons/av_devon.svg',
    budget: 1100,
    location: 'Outer Sunset',
    bio: 'Musician + barista. Headphones are my love language. Quiet apartment, loud songs.',
    traits: [
      Trait(title: 'Music lover', color: Color(0xFF1CB0F6)),
      Trait(title: 'Night owl', color: Color(0xFF0891B2)),
      Trait(title: 'Loves cooking', color: Color(0xFFFF9600)),
      Trait(title: 'Non-smoker', color: Color(0xFF58CC02)),
    ],
    gradient: [Color(0xFF0891B2), Color(0xFF155E75)],
  ),
];
