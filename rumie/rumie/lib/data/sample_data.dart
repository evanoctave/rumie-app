import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../models/trait.dart';

// Trait chip colors — soft tinted backgrounds that read well on light theme
const _green   = Color(0xFF96E6B3); // mint primary
const _forest  = Color(0xFF568259); // forest secondary
const _amber   = Color(0xFFF59E0B); // warm amber
const _teal    = Color(0xFF0D9488); // teal accent
const _blue    = Color(0xFF3B82F6); // blue accent

const List<Roommate> sampleRoommates = [
  Roommate(
    name: 'Maya',
    age: 24,
    avatarAsset: 'assets/icons/av_maya.svg',
    budget: 1200,
    location: 'Mission District',
    bio: 'Grad student, loves plants and quiet evenings. Looking for a chill space to call home.',
    traits: [
      Trait(title: 'Very tidy',  color: _forest),
      Trait(title: 'Night owl',  color: _teal),
      Trait(title: 'Has a cat',  color: _forest),
      Trait(title: 'Studious',   color: _green),
    ],
    gradient: [Color(0xFF96E6B3), Color(0xFF568259)],
  ),
  Roommate(
    name: 'Jordan',
    age: 27,
    avatarAsset: 'assets/icons/av_jordan.svg',
    budget: 1500,
    location: 'SoMa',
    bio: 'Software engineer. Big fan of weekend coffee runs and weekday silence.',
    traits: [
      Trait(title: 'Works from home', color: _forest),
      Trait(title: 'Early bird',      color: _amber),
      Trait(title: 'Non-smoker',      color: _green),
      Trait(title: 'Gamer',           color: _teal),
    ],
    gradient: [Color(0xFF96E6B3), Color(0xFF2D6A4F)],
  ),
  Roommate(
    name: 'Aria',
    age: 22,
    avatarAsset: 'assets/icons/av_aria.svg',
    budget: 900,
    location: 'Oakland',
    bio: 'Art student. I bake a lot. Sometimes paint at 2am. Sorry not sorry.',
    traits: [
      Trait(title: 'Creative',      color: _amber),
      Trait(title: 'Loves cooking', color: _green),
      Trait(title: 'Night owl',     color: _teal),
      Trait(title: 'Vegetarian',    color: _forest),
    ],
    gradient: [Color(0xFF568259), Color(0xFF2D6A4F)],
  ),
  Roommate(
    name: 'Sam',
    age: 29,
    avatarAsset: 'assets/icons/av_sam.svg',
    budget: 1800,
    location: 'Berkeley',
    bio: 'Yoga teacher, dog parent, plant collector. Looking for someone calm and respectful.',
    traits: [
      Trait(title: 'Zen vibes',  color: _green),
      Trait(title: 'Has a dog',  color: _amber),
      Trait(title: 'Early bird', color: _forest),
      Trait(title: 'Very tidy',  color: _teal),
    ],
    gradient: [Color(0xFF96E6B3), Color(0xFF568259)],
  ),
  Roommate(
    name: 'Devon',
    age: 25,
    avatarAsset: 'assets/icons/av_devon.svg',
    budget: 1100,
    location: 'Outer Sunset',
    bio: 'Musician + barista. Headphones are my love language. Quiet apartment, loud songs.',
    traits: [
      Trait(title: 'Music lover', color: _teal),
      Trait(title: 'Night owl',   color: _forest),
      Trait(title: 'Loves cooking', color: _amber),
      Trait(title: 'Non-smoker',  color: _green),
    ],
    gradient: [Color(0xFF568259), Color(0xFF2D6A4F)],
  ),
  Roommate(
    name: 'Riley',
    age: 23,
    avatarAsset: 'assets/icons/av_riley.svg',
    budget: 1350,
    location: 'Hayes Valley',
    bio: 'College senior. Neat, quiet, mostly in class or the library. Great at keeping shared spaces clean.',
    traits: [
      Trait(title: 'Student',     color: _blue),
      Trait(title: 'Very clean',  color: _green),
      Trait(title: 'Early bird',  color: _amber),
      Trait(title: 'Non-smoker', color: _forest),
    ],
    gradient: [Color(0xFF96E6B3), Color(0xFF3B82F6)],
  ),
  Roommate(
    name: 'Alex',
    age: 31,
    avatarAsset: 'assets/icons/av_alex.svg',
    budget: 2000,
    location: 'Nob Hill',
    bio: 'Finance professional. Work hard, relax harder. Enjoy hosting friends on weekends.',
    traits: [
      Trait(title: 'Social',       color: _amber),
      Trait(title: 'Professional', color: _forest),
      Trait(title: 'Host',         color: _teal),
      Trait(title: 'Gym-goer',     color: _green),
    ],
    gradient: [Color(0xFF568259), Color(0xFF96E6B3)],
  ),
  Roommate(
    name: 'Priya',
    age: 26,
    avatarAsset: 'assets/icons/av_priya.svg',
    budget: 1400,
    location: 'Richmond District',
    bio: 'UX designer working hybrid. I cook Indian food almost every night — always sharing.',
    traits: [
      Trait(title: 'Hybrid WFH',    color: _forest),
      Trait(title: 'Loves cooking', color: _amber),
      Trait(title: 'Has plants',    color: _green),
      Trait(title: 'Night owl',     color: _teal),
    ],
    gradient: [Color(0xFF96E6B3), Color(0xFF568259)],
  ),
];
