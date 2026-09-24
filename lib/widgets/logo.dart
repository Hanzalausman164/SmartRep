import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum LogoSize { compact, normal, large }

/// Matches the web prototype's `Logo`: a ring mark + wordmark, with "SMART"
/// in the brand blue and "REP" in foreground. Large size adds a tagline.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = LogoSize.normal});
  final LogoSize size;

  @override
  Widget build(BuildContext context) {
    final markSize = switch (size) { LogoSize.compact => 36.0, LogoSize.large => 88.0, LogoSize.normal => 60.0 };
    final textSize = switch (size) { LogoSize.compact => 18.0, LogoSize.large => 40.0, LogoSize.normal => 26.0 };

    final mark = Container(
      width: markSize,
      height: markSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandBlue, width: math.max(2, markSize * 0.07)),
      ),
      child: Icon(Icons.bolt_rounded, color: AppColors.brandBlue, size: markSize * 0.5),
    );

    final wordmark = RichText(
      text: TextSpan(
        style: AppText.display(size: textSize, weight: FontWeight.w700),
        children: [
          TextSpan(text: 'SMART', style: TextStyle(color: AppColors.brandBlue)),
          const TextSpan(text: 'REP', style: TextStyle(color: AppColors.foreground)),
        ],
      ),
    );

    if (size == LogoSize.large) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(height: 10),
          wordmark,
          const SizedBox(height: 8),
          Text('LIFT SMART, NOT HARD', style: eyebrowStyle(size: 11)),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [mark, const SizedBox(width: 10), wordmark],
    );
  }
}

/// Matches `.bluetooth-signal`: three nested arcs radiating above the logo
/// on the splash screen, echoing a BLE signal pulse.
class BleSignalArcs extends StatelessWidget {
  const BleSignalArcs({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 80,
      height: 46,
      child: CustomPaint(painter: _BleArcsPainter()),
    );
  }
}

class _BleArcsPainter extends CustomPainter {
  const _BleArcsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlue.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final bottomCenter = Offset(size.width / 2, size.height);
    for (final radius in [38.0, 26.0, 14.0]) {
      final rect = Rect.fromCircle(center: bottomCenter, radius: radius);
      // Dome shape: sweep counter-clockwise from the left side, over the
      // top, to the right side (a "signal arc" opening downward).
      canvas.drawArc(rect, math.pi, -math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
