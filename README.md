# Rumie

A Tinder-style roommate matching app, built in Flutter.

-- app not in app store yet but soon to be released in the coming month. Updates will be posted.

## Getting started

This is a starter skeleton — it contains the `lib/`, `assets/`, `test/`, and
`pubspec.yaml`. It does **not** include native Android/iOS/web folders; those
are generated per-machine and depend on your bundle ID, signing config, etc.

To turn this into a runnable project:

```bash
cd rumie
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
rumie/
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
│   ├── data/                 ← API layer (screens never import this)
│   │   ├── api/              ← DioClient, interceptors, token store, openapi.json
│   │   ├── models/           ← DTOs + generated *.g.dart
│   │   └── repositories/     ← *RepositoryImpl (hand-written Dio calls)
│   │
│   ├── domain/               ← what screens import
│   │   ├── entities/         ← entities.dart barrel + UI-facing types
│   │   ├── errors/           ← typed ApiException + user-safe messages
│   │   └── repositories/     ← abstract repository interfaces
│   │
│   ├── di/locator.dart       ← GetIt registrations
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

The app talks to the Rumie API (FastAPI) through a single Dio client. Screens
depend only on the repository interfaces in `lib/domain/repositories/`,
resolved from the GetIt locator in `lib/di/locator.dart`. See `SPEC.md` for
the full contract and invariants.

### Pointing the app at a different server

The base URL is a compile-time define. It defaults to `https://rumie.xyz`, and
`/api/v1` is appended automatically, so pass only the origin:

```bash
cd rumie/rumie
flutter run --dart-define=RUMIE_BASE_URL=http://localhost:8000
# release builds take the same flag
flutter build ios --dart-define=RUMIE_BASE_URL=https://staging.rumie.xyz
```

Android emulators reach the host machine at `http://10.0.2.2:<port>`, not
`localhost`. Plain-`http` servers also need cleartext traffic allowed on
Android and an ATS exception on iOS.

### Refreshing the OpenAPI snapshot

`lib/data/api/openapi.json` is the committed contract that the DTOs in
`lib/data/models/` are derived from. Commit it whenever the API changes:

```bash
cd rumie/rumie
curl -fsSL https://rumie.xyz/openapi.json -o lib/data/api/openapi.json
git diff --stat lib/data/api/openapi.json     # see what changed
```

Then:

1. Update the matching DTOs in `lib/data/models/`. Nullable schema fields
   become `?` and non-nullable ones become `required`; enums use
   `@JsonValue`.
2. Regenerate the serializers:
   `dart run build_runner build --delete-conflicting-outputs`
3. Update the affected repository interfaces and implementations, then run
   `flutter analyze && flutter test`.

### Running the tests

```bash
cd rumie/rumie
flutter test      # repositories run against a fake HTTP adapter, screens against fake repositories
```

The tests never touch the network.
