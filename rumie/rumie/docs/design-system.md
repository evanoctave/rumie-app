# Rumie design system (Oct 2026)

Replaces the brutalist editorial pass. Warm, photo-first, tactile.

## Tokens (`lib/theme/`)

| File | What |
|---|---|
| `app_colors.dart` | Paper ground, violet-tinted ink, iris accent, semantic colors, shadows. Light and dark via `AppColors.isDark` (driven by `ThemeProvider`). |
| `app_text.dart` | Type scale. Display: Bricolage Grotesque 700/800. Body: DM Sans 400–700. Both bundled in `assets/fonts/`, no runtime fetch. |
| `app_shapes.dart` | Superellipse radii: card 28, photo 24, tile 20, button 18, input 16. |
| `app_motion.dart` | Durations (130 / 220 / 360 / 480 ms), ease-out curves, `AppMotion.of(context, d)` returns zero under reduced motion. |
| `app_theme.dart` | `ThemeData` builder. Call `AppTheme.build(dark)`. |

## Primitives (`lib/widgets/ui/`)

`Pressable` (scale on press, used by every custom tap target), `AppButton`, `CircleButton`, `AppChip`, `AppTextField` (focus halo), `AppSegmented` (sliding thumb), `ScreenHeader`, `Reveal` (staggered fade-rise), `RumiePhoto` / `Avatar`, `ScoreRing` / `MiniBar`, `showAppDialog`, `AppSheet` / `showAppSheet`, `showTopToast`, `Wordmark`, `SettingsGroup` / `ToggleRow` / `NavRow`.

## Motion map

- Discover: cards reveal with stagger; photos parallax against scroll (`ParallaxPhoto`); Pass slides a card left and collapses the gap, Connect slides right and drops a toast; tapping a card flies the photo into the profile header (`Hero`).
- Nav: accent capsule slides between tabs; tabs stay mounted and cross-fade.
- Matches → Chat: avatar hero; bubbles scale and rise in; send button enables with scale.
- Listings: score rings sweep and count up; factor bars grow.
- Forms: segmented thumb slides; chips cross-fade; fields glow on focus.
- Landing: photo wall drifts slowly; wordmark and buttons rise in.

## Dev flags

```bash
# Skip the backend, open with sample data
flutter run --dart-define=RUMIE_DEMO=true

# Open straight into one screen (discover, matches, listings, profile,
# profile-view, chat, settings, create, landing, login, signup, lock)
flutter run --dart-define=RUMIE_DEMO=true --dart-define=RUMIE_START=chat

# Scripted tour with screenshots
RUMIE_SHOTS=build/tour flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/tour_test.dart \
  -d <device> --dart-define=RUMIE_DEMO=true
```
