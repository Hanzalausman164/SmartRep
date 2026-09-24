import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/logo.dart';

/// Matches `RestScreen`: a countdown ring between sets, +/- adjustment, and
/// actions to begin the next set or end the workout early.
class RestScreen extends StatefulWidget {
  const RestScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  static const _startSeconds = 90;
  int _seconds = 75;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds = (_seconds - 1).clamp(0, 999));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formatted => '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Logo(size: LogoSize.compact),
              Text('SET 2 / 3', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 20),
          Text('SET COMPLETE', style: eyebrowStyle(color: AppColors.qualityGood)),
          const SizedBox(height: 6),
          Text('Recover with purpose', style: AppText.display(size: 26, weight: FontWeight.w700)),
          const SizedBox(height: 28),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _RestRingPainter(progress: (_seconds / _startSeconds).clamp(0, 1)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatted, style: AppText.display(size: 52, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Until set 3', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border))),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatItem(label: 'Reps', value: '10 / 10'),
                StatItem(label: 'Avg. quality', value: '86'),
                StatItem(label: 'Avg. ROM', value: '88%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _seconds = (_seconds - 15).clamp(0, 999)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('\u221215 sec'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _seconds += 15),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('+15 sec'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: () => widget.go(AppScreen.tracking),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.play_arrow, size: 16), SizedBox(width: 8), Text('Begin set 3')],
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => widget.go(AppScreen.summary),
            child: Text('End workout & view summary', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
          ),
        ],
      ),
    );
  }
}

class _RestRingPainter extends CustomPainter {
  const _RestRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;

    final track = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, track);

    final progressPaint = Paint()
      ..color = AppColors.foreground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const startAngle = -math.pi / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RestRingPainter oldDelegate) => oldDelegate.progress != progress;
}
