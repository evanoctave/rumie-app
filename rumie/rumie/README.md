# Rumie

**Find your people. Find your place.**

Rumie is a college roommate-finding and housing-selection app: Hinge-style
roommate discovery, Zillow-style housing browse, and Airbnb-style trust —
in one guided flow. Built in Flutter.

## What's in the app

| Tab | What it does |
|-----|--------------|
| **Discover** | Swipe through roommate candidates ranked by a local compatibility engine. Match %, "why you match" reasons, quick filters, save-for-later, full profile detail. |
| **Housing** | Browse listings with filters (near campus, price, pet friendly, furnished, verified). Tap into a rich detail page with amenities, safety notes, and group CTAs. |
| **Matches** | Mutual matches with last-message preview, unread counts, and match %. Tap into chat. |
| **Saved** | Saved roommates and saved listings in one place, plus the entry to your roommate **Group**. |
| **Profile** | Your profile hub: completion meter, edit flow, Settings, and the Safety Center. |

Supporting screens: roommate detail, housing detail, chat thread (with safety
reminder), roommate groups, Settings, and a full Safety Center.

## Getting started

```bash
flutter pub get
flutter run
```

If the native platform folders are ever missing on a fresh machine:

```bash
flutter create --org com.example .   # fills in only missing platform code
```

### Environment configuration

All domain knowledge lives in `lib/core/config/env.dart`. The production
API/app domain is **rumie.xyz** (`rumie.tech` is reserved for the dev /
landing / docs site and is never referenced by the app).

```bash
# default: https://rumie.xyz  (API base = https://rumie.xyz/api/v1)
flutter run

# point at a local or staging backend:
flutter run --dart-define=RUMIE_BASE_URL=http://localhost:8000
flutter run --dart-define=RUMIE_BASE_URL=https://staging.rumie.xyz
```

## Architecture

```
lib/
├── core/
│   ├── config/env.dart           ← RUMIE_BASE_URL + /api/v1 (single source)
│   └── utils/profile_styles.dart ← gradient/chip-color derivation for entities
├── theme/
│   ├── app_colors.dart           ← adaptive light/dark palette
│   └── tokens.dart               ← spacing, radii, motion durations
├── domain/
│   ├── entities/                 ← RoommateProfile, RoommateCandidate,
│   │                                HousingListing, RoommateMatch,
│   │                                RoommateGroup, lifestyle enums
│   ├── repositories/             ← abstract interfaces (UI depends only on these)
│   └── services/
│       └── compatibility_service.dart ← rule-based 0–100 scoring + reasons
├── data/
│   ├── api/                      ← Dio client, interceptors, secure token store
│   ├── models/                   ← OpenAPI DTOs (json_serializable)
│   ├── repositories/             ← live-API repository implementations
│   └── mock/                     ← centralized mock data + mock repositories
├── state/                        ← ChangeNotifier providers per feature
├── screens/                      ← one file per screen
├── widgets/                      ← Rumie design-system components
└── di/locator.dart               ← GetIt registrations
```

### Live API vs. mock data

Auth (register/login/refresh/me) already talks to the live API at
`https://rumie.xyz/api/v1` with JWT bearer tokens in
`flutter_secure_storage`, automatic single-flight refresh, and typed
exceptions.

The product surfaces (discover feed, housing, groups) run on **mock
repositories** so the UX is complete before the matching/housing endpoints
ship. The UI only knows the interfaces, so going live is a one-line swap per
repository in `lib/di/locator.dart`:

```dart
// today
..registerLazySingleton<RoommateFeedRepository>(MockRoommateFeedRepository.new)
// when GET /api/v1/roommates/discover ships
..registerLazySingleton<RoommateFeedRepository>(() => ApiRoommateFeedRepository(locator<Dio>()))
```

The compatibility engine (`CompatibilityService`) is similarly modular: the
Discover feed consumes its `CompatibilityResult`, so a backend/ML ranker can
replace it without UI changes.

### Design system

`lib/widgets/` holds the reusable kit: `RumieButton`, `RumieCard`,
`RumieChip`, `RumieTextField`, `RumieAvatar`, `MatchScorePill`,
`VerificationBadge`, `ProfileCompletionMeter`, `HousingListingCard`,
`MatchTile`, `EmptyState`, `SkeletonCard`, `SectionHeader`, `SaveButton`,
`SafetyNotice`. Spacing/radii/motion come from `lib/theme/tokens.dart`;
colors from `lib/theme/app_colors.dart` (light + dark).

## Troubleshooting: iOS builds inside iCloud-synced folders

This repo lives under `~/Documents`, which macOS syncs to iCloud. iCloud
re-applies `com.apple.FinderInfo` attributes to freshly written build
artifacts, which makes `codesign` fail with *"resource fork, Finder
information, or similar detritus not allowed."* Two mitigations are in place:

1. `ios/Podfile` sets `CODE_SIGNING_ALLOWED = NO` for pod targets (pods are
   re-signed by the app when embedded, so this is safe).
2. The `build/` directory is a local symlink to
   `~/Library/Caches/rumie-build` (outside iCloud). If you ever delete it,
   recreate it with:

   ```bash
   rm -rf build && mkdir -p ~/Library/Caches/rumie-build && ln -s ~/Library/Caches/rumie-build build
   ```

   (Or move the repo out of an iCloud-synced folder and use a plain `build/`.)

## Quality checks

```bash
dart format .
flutter analyze
flutter test
```

## Refreshing the OpenAPI snapshot

DTOs are generated from the committed snapshot at
`lib/data/api/openapi.json` (canonical source:
`https://rumie.xyz/openapi.json`). After updating the snapshot:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Backend endpoints the app is shaped around

Already live: `POST /auth/register`, `POST /auth/login`,
`POST /auth/refresh`, `GET /me`, plus groups/listings/swipes/conversations
per the OpenAPI snapshot.

Needed to take the product surfaces live:

- `GET /roommates/discover` · `GET /roommates/{id}` ·
  `POST /roommates/{id}/like|pass|save`
- `GET /housing/listings` · `GET /housing/listings/{id}` ·
  `POST/DELETE /housing/listings/{id}/save`
- `GET /matches` · conversations endpoints for real chat
- `GET /groups/me` · `POST /groups/{id}/attach-listing`
- `POST /auth/verify-email` (student verification)
- `POST /reports` · `POST /blocks` (Safety Center)
