import 'dart:async';

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../widgets/logo.dart';

/// Matches the prototype's minimal splash: a centered logo lockup with a
/// soft radial glow, then advances to authentication after a brief pause.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  Timer? _transitionTimer;

  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  late final Animation<double> _entranceFade;
  late final Animation<double> _entranceSlideY;
  late final Animation<double> _entranceScale;

  @override
  void initState() {
    super.initState();
    _transitionTimer = Timer(const Duration(seconds: 2), _continue);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowOpacity = Tween<double>(begin: 0.10, end: 0.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceSlideY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _continue() {
    _transitionTimer?.cancel();
    if (mounted) widget.go(AppScreen.auth);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _continue,
      child: Container(
        color: AppColors.background,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowScale.value,
                    child: Container(
                      width: 520,
                      height: 520,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.brandBlue.withValues(alpha: _glowOpacity.value),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.65],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Opacity(
                  opacity: _entranceFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _entranceSlideY.value - 25),
                    child: Transform.scale(
                      scale: _entranceScale.value,
                      child: const Logo(size: LogoSize.large, muted: false),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
