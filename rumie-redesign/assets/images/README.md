# Images

Profile photos, backgrounds, illustrations — anything that isn't a small icon.

This folder is already declared in `pubspec.yaml`, so anything you drop here
will be bundled with the app.

## Usage

```dart
Image.asset('assets/images/onboarding_1.png')
```

## Tip: providing @2x and @3x

Flutter automatically picks higher-resolution variants if you follow this layout:

```
assets/images/profile_placeholder.png       (1x)
assets/images/2.0x/profile_placeholder.png  (2x)
assets/images/3.0x/profile_placeholder.png  (3x)
```

Only the 1x path needs to be referenced in code; Flutter resolves the rest.
