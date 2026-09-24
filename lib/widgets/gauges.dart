import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Matches `RomBar`: a 4-band vertical track (poor/warn/good/poor) with a
/// draggable-looking puck positioned by `value` (0-100, bottom-up).
class RomBar extends StatelessWidget {
  const RomBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        children: const [
                          Expanded(child: ColoredBox(color: AppColors.qualityPoor)),
                          Expanded(child: ColoredBox(color: AppColors.qualityWarn)),
                          Expanded(child: ColoredBox(color: AppColors.qualityGood)),
                          Expanded(child: ColoredBox(color: AppColors.qualityPoor)),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment(0, 1 - (value.clamp(0, 100) / 100) * 2),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.foreground,
                      border: Border.all(color: AppColors.background, width: 6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MAXIMUM', style: eyebrowStyle(size: 9)),
                  Text('TARGET RANGE', style: eyebrowStyle(size: 9)),
                  Text('MINIMUM', style: eyebrowStyle(size: 9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matches `SpeedGauge`: a semicircular speed dial with a needle, an "ideal"
/// arc band, and a status label (Too slow / Slow / Ideal / Fast / Too fast).
class SpeedGauge extends StatelessWidget {
  const SpeedGauge({super.key, required this.speed});
  final double speed;

  String get _status {
    if (speed < 0.55) return 'Too slow';
    if (speed < 0.8) return 'Slow';
    if (speed <= 1.25) return 'Ideal';
    if (speed <= 1.5) return 'Fast';
    return 'Too fast';
  }

  Color get _statusColor {
    if (_status == 'Ideal') return AppColors.qualityGood;
    if (_status == 'Slow' || _status == 'Fast') return AppColors.qualityWarn;
    return AppColors.qualityPoor;
  }

  @override
  Widget build(BuildContext context) {
    final angle = -70 + (speed / 1.8).clamp(0, 1) * 140;
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: CustomPaint(
            painter: _GaugePainter(angleDegrees: angle.toDouble()),
            child: const SizedBox(width: 176, height: 100),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -16),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: AppText.display(size: 30, weight: FontWeight.w700),
                  children: [
                    TextSpan(text: speed.toStringAsFixed(2)),
                    TextSpan(text: ' m/s', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(_status.toUpperCase(), style: eyebrowStyle(color: _statusColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.angleDegrees});
  final double angleDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 180;
    canvas.save();
    canvas.scale(scale);

    final track = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final trackPath = Path()..moveTo(25, 90)..arcToPoint(const Offset(155, 90), radius: const Radius.circular(65));
    canvas.drawPath(trackPath, track);

    final good = Paint()
      ..color = AppColors.qualityGood
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.butt;
    final goodPath = Path()..moveTo(39, 52)..arcToPoint(const Offset(141, 52), radius: const Radius.circular(65));
    canvas.drawPath(goodPath, good);

    canvas.translate(90, 90);
    canvas.rotate(angleDegrees * math.pi / 180);
    final needle = Paint()..color = AppColors.foreground;
    final needlePath = Path()
      ..moveTo(0, 0)
      ..lineTo(-4, -52)
      ..lineTo(4, -52)
      ..close();
    canvas.drawPath(needlePath, needle);
    canvas.drawCircle(Offset.zero, 8, needle);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.angleDegrees != angleDegrees;
}

/// Matches `Sparkline`: a light dashed 3-line grid with a connected polyline
/// + dots trend chart, used on the summary and profile screens.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      width: double.infinity,
      child: CustomPaint(painter: _SparklinePainter(values: values)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 300;
    final scaleY = size.height / 110;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final y in [100.0, 65.0, 30.0]) {
      _drawDashedLine(canvas, Offset(8, y), Offset(292, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = 8 + i * (284 / (values.length - 1));
      final y = 100 - values[i] * 0.78;
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = AppColors.foreground
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotFill = Paint()..color = AppColors.background;
    final dotStroke = Paint()
      ..color = AppColors.foreground
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotFill);
      canvas.drawCircle(p, 3, dotStroke);
    }
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 3.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    var covered = 0.0;
    while (covered < distance) {
      final segStart = start + direction * covered;
      final segEnd = start + direction * math.min(covered + dashWidth, distance);
      canvas.drawLine(segStart, segEnd, paint);
      covered += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values;
}
