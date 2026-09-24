import 'dart:async';
import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/logo.dart';

/// Matches `SplashScreen`: centered logo with BLE arcs, a soft radial glow,
/// a pulsing ring, and a progress bar with "Preparing sensors" label.
///
/// The original left its auto-advance timer commented out (manual-advance
/// prototype mode); this keeps that same behavior — tap to continue — since
/// that's the real, intended interaction, not a leftover to silently "fix".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 6;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      setState(() => _progress = (_progress + 4).clamp(0, 100));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.go(AppScreen.auth),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.foreground.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
          Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [BleSignalArcs(), SizedBox(height: 4), Logo(size: LogoSize.large)],
          ),
          Positioned(
            left: 40,
            right: 40,
            bottom: 64,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
                    child: Stack(
                      children: [
                        Container(color: AppColors.secondary),
                        FractionallySizedBox(
                          widthFactor: _progress / 100,
                          child: Container(color: AppColors.foreground),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bluetooth, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Text('PREPARING SENSORS', style: eyebrowStyle()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
