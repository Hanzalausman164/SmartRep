# SmartRep (Flutter)

A Flutter port of the SmartRep gym-tracking prototype, continuing the work
started in an earlier Claude chat. All 11 screens from the original design
are implemented.

## Run it

```bash
flutter pub get
flutter run
```

Requires a fairly recent Flutter SDK (3.27+) since the code uses the newer
`Color.withValues(alpha: ...)` API. If your SDK is older, either upgrade
(`flutter upgrade`) or swap those calls for `.withOpacity(...)`.

## What was reconstructed vs. what your friend already had

Only 4 files survived from the earlier chat: `main.dart`, `app_root.dart`,
`splash_screen.dart`, and `gauges.dart`. Those are kept as-is (one small
change: `app_root.dart` now wraps the screen in a `Material` widget instead
of a plain `DecoratedBox`, so ripple effects like the bottom nav don't throw
at runtime).

Everything else — the theme, shared widgets, and the other 10 screens
(auth, scan, connecting, reservation, calibration, tracking, rest, summary,
profile, unavailable) — was rebuilt from scratch to match the visual
language established in those 4 files and the original web prototype
(`smart-rep-app-main.zip`) you uploaded.

## Known placeholders / things to swap in

- **Machine artwork** (`lib/widgets/common.dart` → `MachineArtwork`): the
  original used a credited Flaticon PNG that wasn't in the files you had.
  It's currently a bordered box with a dumbbell icon. Replace with
  `Image.asset('assets/images/lat_pulldown.png')` once you add the real
  asset and register it under `flutter: assets:` in `pubspec.yaml`.
- **Fonts**: uses `google_fonts` (Barlow Condensed + Manrope) to match the
  web prototype, fetched at runtime. Swap for bundled font files if you
  need offline-first builds.
- **Lucide icon names**: I used the most likely Flutter `lucide_icons`
  equivalents of the icons in the web version. A couple of names may need
  a small tweak once you run `flutter pub get` and see the actual package
  API — `flutter analyze` will point out any that don't exist.
- All screens use simulated/mock data (matching the original prototype's
  "Lovable" simulated flow) rather than real BLE/sensor integration.

I wasn't able to run `flutter pub get` / `flutter analyze` in this
environment (no Flutter SDK, no network), so please run both after
unzipping — happy to fix anything that comes up.
