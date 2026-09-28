# SmartRep (Flutter)

A Flutter port of the SmartRep gym-tracking prototype.

## Run it

```bash
flutter pub get
flutter run
```

Requires a fairly recent Flutter SDK (3.27+) since the code uses the newer
`Color.withValues(alpha: ...)` API. If your SDK is older, either upgrade
(`flutter upgrade`) or swap those calls for `.withOpacity(...)`.

