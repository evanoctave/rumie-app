# Rumie

A Tinder-style roommate matching app, built in Flutter.

## Getting started

This is a starter skeleton — it contains the `lib/`, `assets/`, `test/`, and
`pubspec.yaml`. It does **not** include native Android/iOS/web folders; those
are generated per-machine and depend on your bundle ID, signing config, etc.

To turn this into a runnable project:

```bash
cd roomie
flutter create --org com.example .    # generates android/, ios/, web/, etc.
flutter pub get                        # install packages
flutter run
```

`flutter create .` over an existing folder fills in only the missing platform
code — it leaves your `lib/`, `pubspec.yaml`, and `assets/` untouched.

## App structure

Three bottom tabs, matching the whiteboard sketch:

| Tab          | Icon | What it does                                                  |
|--------------|------|---------------------------------------------------------------|
| **Listings** | 🏠   | Browseable list of all roommates. Tap one for a detail sheet. |
| **Swiping**  | 🎴   | The swipe deck. Default tab on app open.                      |
| **Profile**  | 😊   | Your own profile + preferences.                               |

Matches are reached via the 💜 icon in the Swiping tab's header — it shows a
badge with the count and pushes the matches list when tapped.

## Folder layout

```
roomie/
├── pubspec.yaml              ← dependencies + asset declarations
├── analysis_options.yaml     ← lint rules
├── .gitignore
│
├── lib/
│   ├── main.dart             ← entry point + MaterialApp
│   │
│   ├── theme/
│   │   └── app_colors.dart   ← all colors live here
│   │
│   ├── data/
│   │   ├── api/              ← DioClient, interceptors, openapi.json snapshot
│   │   ├── models/           ← DTOs + generated *.g.dart
│   │   └── repositories/     ← *RepositoryImpl
│   │
│   ├── screens/
│   │   ├── home_screen.dart      ← bottom-nav shell
│   │   ├── listings_screen.dart  ← browse list + detail sheet
│   │   ├── swipe_screen.dart     ← swipe deck (default)
│   │   ├── matches_screen.dart   ← reached via 💜 in swipe header
│   │   └── profile_screen.dart   ← your own profile + prefs
│   │
│   └── widgets/
│       ├── roommate_card.dart    ← swipeable card + photo dots
│       ├── listing_card.dart     ← compact row in Listings tab
│       ├── trait_chip.dart       ← lifestyle pill
│       ├── action_button.dart    ← ✕ / ✓ swipe buttons
│       ├── nav_item.dart         ← bottom nav button
│       ├── match_tile.dart       ← row in matches list
│       ├── pref_row.dart         ← row in profile preferences
│       └── stamp.dart            ← MATCH! / PASS overlay
│
├── assets/
│   ├── icons/                ← drop PNG/SVG icons here  (README inside)
│   ├── images/               ← profile photos, illustrations
│   └── fonts/                ← .ttf / .otf files
│
└── test/
    └── widget_test.dart      ← smoke test
```

## What matches the sketch

- **3 bottom tabs** (`Listings 🏠`, `Swiping 🎴`, `Profile 😊`) — your 3 red dots
- **Swipe deck** as default landing screen
- **Photo carousel dots** at the top of each card — your "`now ○○○○○`" annotation. Tap the left third of the photo to go back, right two-thirds to advance. Placeholder gradient + emoji until real photos are wired up.
- **Two action buttons** (`✕` / `✓`) — your X and checkmark, instead of the old three-button setup
- **Pill-shaped trait chips** — your "pill interactives"
- **Listing detail sheet** — tap a row in the Listings tab to see the full profile in a draggable bottom sheet

## Backend API

Data comes from the Rumie API (default `https://rumie.xyz`; override it with
`--dart-define=RUMIE_BASE_URL=...`). The repository README at the repo root
explains how to configure the base URL and refresh the OpenAPI snapshot.
