# Fonts

Drop .ttf or .otf files here, then declare them in `pubspec.yaml`.

## Recommended fonts for the Duolingo-ish vibe

- **Nunito** — rounded, friendly, has weights 200–900. https://fonts.google.com/specimen/Nunito
- **Quicksand** — geometric and very round. https://fonts.google.com/specimen/Quicksand
- **Fredoka** — chunky, playful, very Duolingo-feel. https://fonts.google.com/specimen/Fredoka

## How to wire one up

1. Download the .ttf files into this folder, e.g.:
   ```
   assets/fonts/Nunito-Regular.ttf
   assets/fonts/Nunito-Bold.ttf
   assets/fonts/Nunito-ExtraBold.ttf
   ```

2. Uncomment the `fonts:` section in `pubspec.yaml`.

3. Add `fontFamily: 'Nunito'` to the `ThemeData` in `lib/main.dart`.

4. Run `flutter pub get` and hot-restart.
