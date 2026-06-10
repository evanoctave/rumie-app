# Icons

Drop your icon files (PNG or SVG) into this folder.

The folder is already declared in `pubspec.yaml`, so anything you put here will be
bundled with the app automatically.

## Using a PNG icon

```dart
Image.asset('assets/icons/home.png', width: 32, height: 32)
```

## Using an SVG icon

SVGs require the `flutter_svg` package:

```yaml
# pubspec.yaml
dependencies:
  flutter_svg: ^2.0.10
```

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset('assets/icons/home.svg', width: 32, height: 32)
```

## Suggested icon set

If you want the Duolingo-style chunky-friendly look without designing your own:

- **Fluent UI Emoji** (Microsoft, MIT licensed) — https://github.com/microsoft/fluentui-emoji
- **Noto Emoji** (Google, Apache 2.0) — https://github.com/googlefonts/noto-emoji
- **Iconify** has many free SVG sets — https://icon-sets.iconify.design
- **Twemoji** (Twitter, CC-BY 4.0) — https://github.com/twitter/twemoji

For now the app uses Unicode emoji directly (no asset files needed), which renders
the system emoji font. Replace those with PNG/SVG assets here when you want a
consistent cross-platform look.
