import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/connecting_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/rest_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/unavailable_screen.dart';
import 'theme/app_colors.dart';

enum AppScreen {
  splash,
  auth,
  scan,
  connecting,
  reservation,
  calibration,
  tracking,
  rest,
  summary,
  profile,
  unavailable,
}

/// A callback screens use to move to another screen, matching the original
/// prototype's `go(target)` function.
typedef GoTo = void Function(AppScreen screen);

/// Hosts the single active screen and swaps it via [GoTo], mirroring how the
/// Lovable prototype swaps screens with plain state rather than a real
/// navigation stack. (The prototype's desktop sidebar / screen picker was
/// just Lovable preview tooling and isn't part of the real app, so it isn't
/// reproduced here — every one of its 11 screens is, though.)
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppScreen _screen = AppScreen.splash;

  void _go(AppScreen target) => setState(() => _screen = target);

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_screen) {
      AppScreen.splash => SplashScreen(go: _go),
      AppScreen.auth => AuthScreen(go: _go),
      AppScreen.scan => ScanScreen(go: _go),
      AppScreen.connecting => ConnectingScreen(go: _go),
      AppScreen.reservation => ReservationScreen(go: _go),
      AppScreen.calibration => CalibrationScreen(go: _go),
      AppScreen.tracking => TrackingScreen(go: _go),
      AppScreen.rest => RestScreen(go: _go),
      AppScreen.summary => SummaryScreen(go: _go),
      AppScreen.profile => ProfileScreen(go: _go),
      AppScreen.unavailable => UnavailableScreen(go: _go),
    };

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(key: ValueKey(_screen), child: body),
        ),
      ),
    );
  }
}
