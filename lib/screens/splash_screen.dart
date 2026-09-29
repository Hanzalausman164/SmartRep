import 'dart:async';

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../widgets/logo.dart';

/// Matches the prototype's `SplashScreen`: the muted logo lockup with
/// pulsing BLE arcs over a soft white radial glow. (The prototype waits for
/// its "Next screen" button; the real app advances on its own after a couple
/// of pulses, or immediately on tap.)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Fade in on the first frame, then hold long enough to see the arcs pulse.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _timer = Timer(const Duration(milliseconds: 5000), _continue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    _timer?.cancel();
    if (mounted) widget.go(AppScreen.auth);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _continue,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // `size-[520px] rounded-full radial-gradient(foreground 11% -> transparent 65%)`
            IgnorePointer(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.foreground.withValues(alpha: 0.11),
                      AppColors.foreground.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.92],
                  ),
                ),
              ),
            ),
            // `-translate-y-[25px]`
            Transform.translate(
              offset: const Offset(0, -25),
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: const Logo(size: LogoSize.large, muted: true, animatedSignal: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
