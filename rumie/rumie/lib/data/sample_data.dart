import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../models/trait.dart';

/// Placeholder data. Replace with a real API/Firebase/etc. when you wire up a backend.
const List<Roommate> sampleRoommates = [
  Roommate(
    name: 'Maya',
    age: 24,
    emoji: '🌸',
    budget: 1200,
    location: 'Mission District',
    bio: 'Grad student, loves plants and quiet evenings. Looking for a chill space to call home.',
    traits: [
      Trait('🧹', 'Very tidy'),
      Trait('🌙', 'Night owl'),
      Trait('🐱', 'Has a cat'),
      Trait('📚', 'Studious'),
    ],
    gradient: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  ),
  Roommate(
    name: 'Jordan',
    age: 27,
    emoji: '🎮',
    budget: 1500,
    location: 'SoMa',
    bio: 'Software engineer. Big fan of weekend coffee runs and weekday silence.',
    traits: [
      Trait('💼', 'Works from home'),
      Trait('☀️', 'Early bird'),
      Trait('🚭', 'Non-smoker'),
      Trait('🎮', 'Gamer'),
    ],
    gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  ),
  Roommate(
    name: 'Aria',
    age: 22,
    emoji: '🎨',
    budget: 900,
    location: 'Oakland',
    bio: 'Art student. I bake a lot. Sometimes paint at 2am. Sorry not sorry.',
    traits: [
      Trait('🎨', 'Creative'),
      Trait('🍳', 'Loves cooking'),
      Trait('🌙', 'Night owl'),
      Trait('🌱', 'Vegetarian'),
    ],
    gradient: [Color(0xFFF472B6), Color(0xFFA78BFA)],
  ),
  Roommate(
    name: 'Sam',
    age: 29,
    emoji: '🧘',
    budget: 1800,
    location: 'Berkeley',
    bio: 'Yoga teacher, dog parent, plant collector. Looking for someone calm and respectful.',
    traits: [
      Trait('🧘', 'Zen vibes'),
      Trait('🐶', 'Has a dog'),
      Trait('☀️', 'Early bird'),
      Trait('🧹', 'Very tidy'),
    ],
    gradient: [Color(0xFFC084FC), Color(0xFFF472B6)],
  ),
  Roommate(
    name: 'Devon',
    age: 25,
    emoji: '🎵',
    budget: 1100,
    location: 'Outer Sunset',
    bio: 'Musician + barista. Headphones are my love language. Quiet apartment, loud songs.',
    traits: [
      Trait('🎵', 'Music lover'),
      Trait('🌙', 'Night owl'),
      Trait('🍳', 'Loves cooking'),
      Trait('🚭', 'Non-smoker'),
    ],
    gradient: [Color(0xFFEC4899), Color(0xFFC084FC)],
  ),
];
