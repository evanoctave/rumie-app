import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../models/trait.dart';

const List<Roommate> sampleRoommates = [
  Roommate(
    name: 'Marcus',
    age: 24,
    avatarAsset: 'assets/images/evan_1.jpg',
    budget: 1200,
    location: 'Mission District',
    bio: 'Grad student, loves music and late nights. Looking for a chill space to call home.',
    traits: [
      Trait(title: 'Very tidy',  color: Color(0xFF10B981)),
      Trait(title: 'Night owl',  color: Color(0xFF7C3AED)),
      Trait(title: 'Gamer',      color: Color(0xFFEC4899)),
      Trait(title: 'Studious',   color: Color(0xFFF59E0B)),
    ],
    gradient: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  ),
  Roommate(
    name: 'Jordan',
    age: 27,
    avatarAsset: 'assets/images/evan_4.jpg',
    budget: 1500,
    location: 'SoMa',
    bio: 'Software engineer. Big fan of weekend coffee runs and weekday silence.',
    traits: [
      Trait(title: 'Works from home', color: Color(0xFF3B82F6)),
      Trait(title: 'Early bird',      color: Color(0xFFF59E0B)),
      Trait(title: 'Non-smoker',      color: Color(0xFF10B981)),
      Trait(title: 'Gamer',           color: Color(0xFF7C3AED)),
    ],
    gradient: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
  ),
  Roommate(
    name: 'Malik',
    age: 22,
    avatarAsset: 'assets/images/evan_2.jpg',
    budget: 900,
    location: 'Oakland',
    bio: 'Art student. I cook a lot. Sometimes paint at 2am. Not sorry about it.',
    traits: [
      Trait(title: 'Creative',      color: Color(0xFFEC4899)),
      Trait(title: 'Loves cooking', color: Color(0xFFF97316)),
      Trait(title: 'Night owl',     color: Color(0xFF7C3AED)),
      Trait(title: 'Vegetarian',    color: Color(0xFF10B981)),
    ],
    gradient: [Color(0xFFEC4899), Color(0xFFF97316)],
  ),
  Roommate(
    name: 'Darius',
    age: 25,
    avatarAsset: 'assets/images/evan_3.jpg',
    budget: 1800,
    location: 'Berkeley',
    bio: 'Fitness lover, sneaker head, plant collector. Looking for someone calm and respectful.',
    traits: [
      Trait(title: 'Gym rat',      color: Color(0xFF14B8A6)),
      Trait(title: 'Sneaker head', color: Color(0xFFF59E0B)),
      Trait(title: 'Early bird',   color: Color(0xFF10B981)),
      Trait(title: 'Very tidy',    color: Color(0xFF7C3AED)),
    ],
    gradient: [Color(0xFF14B8A6), Color(0xFF10B981)],
  ),
  Roommate(
    name: 'Devon',
    age: 25,
    avatarAsset: 'assets/images/evan_1.jpg',
    budget: 1100,
    location: 'Outer Sunset',
    bio: 'Musician + barista. Headphones are my love language. Quiet apartment, loud songs.',
    traits: [
      Trait(title: 'Music lover',   color: Color(0xFFF97316)),
      Trait(title: 'Night owl',     color: Color(0xFF7C3AED)),
      Trait(title: 'Loves cooking', color: Color(0xFFF59E0B)),
      Trait(title: 'Non-smoker',    color: Color(0xFF10B981)),
    ],
    gradient: [Color(0xFFF97316), Color(0xFFF59E0B)],
  ),
];
