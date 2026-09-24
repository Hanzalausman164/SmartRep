import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';

/// Matches `TrackingScreen`: live rep count, ROM bar + speed gauge side by
/// side, per-set stats, and a dismissible form-warning card.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _rep = 6;
  bool _warning = false;

  static const _romValues = [86, 91, 94, 88, 82, 74, 68, 92, 89, 85];
  static const _speedValues = [0.92, 1.02, 1.1, 0.98, 0.84, 0.62, 0.54, 1.08, 0.93, 0.88];

  int get _rom => _romValues[(_rep - 1) % _romValues.length];
  double get _speed => _speedValues[(_rep - 1) % _speedValues.length];

  void _advance() {
    if (_rep >= 10) {
      widget.go(AppScreen.rest);
      return;
    }
    setState(() {
      _rep++;
      if (_rep == 7) _warning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            TopBar(
              title: 'Lat Pulldown',
              onBack: () => widget.go(AppScreen.reservation),
              action: IconButton(icon: const Icon(Icons.pause, size: 18), onPressed: () => widget.go(AppScreen.rest)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SET 2 OF 3', style: eyebrowStyle()),
                              RichText(
                                text: TextSpan(
                                  style: AppText.display(size: 60, weight: FontWeight.w700).copyWith(height: 0.85),
                                  children: [
                                    TextSpan(text: '$_rep'),
                                    TextSpan(text: '/10', style: AppText.sans(size: 18, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('LAST REP', style: eyebrowStyle(size: 9)),
                              Text('GOOD \u00b7 87', style: AppText.sans(size: 12, weight: FontWeight.w700, color: AppColors.qualityGood)),
                              Text('+3 vs previous', style: AppText.sans(size: 10, color: AppColors.qualityGood)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('RANGE OF MOTION', style: eyebrowStyle(size: 9)),
                                        Text('$_rom%', style: AppText.display(size: 28, weight: FontWeight.w700)),
                                      ],
                                    ),
                                    Text(
                                      _rom > 80 ? '+2%' : '\u22128%',
                                      style: AppText.sans(size: 10, weight: FontWeight.w700, color: _rom > 80 ? AppColors.qualityGood : AppColors.qualityWarn),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                RomBar(value: _rom.clamp(18, 92).toDouble()),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 260, color: AppColors.border),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REP SPEED', style: eyebrowStyle(size: 9)),
                                SpeedGauge(speed: _speed),
                                const SizedBox(height: 8),
                                const Divider(color: AppColors.border, height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TOP PAUSE', style: eyebrowStyle(size: 9)),
                                    RichText(
                                      text: TextSpan(
                                        style: AppText.display(size: 20, weight: FontWeight.w700),
                                        children: [const TextSpan(text: '0.8'), TextSpan(text: 's', style: AppText.sans(size: 10, color: AppColors.mutedForeground))],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(flex: 2, child: Container(height: 3, color: AppColors.qualityGood)),
                                    const SizedBox(width: 2),
                                    Expanded(child: Container(height: 3, color: AppColors.secondary)),
                                    const SizedBox(width: 2),
                                    Expanded(child: Container(height: 3, color: AppColors.secondary)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('PAUSE HELD', style: eyebrowStyle(size: 9, color: AppColors.qualityGood)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          StatItem(label: 'Tempo', value: '2.1 \u00b7 0.8 \u00b7 2.4'),
                          StatItem(label: 'Consistency', value: '91%'),
                          StatItem(label: 'Set quality', value: '86 / 100'),
                        ],
                      ),
                    ),
                    PrimaryButton(
                      onPressed: _advance,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_rep >= 10 ? 'Finish set' : 'Simulate next rep'),
                          const SizedBox(width: 8),
                          const Icon(Icons.monitor_heart, size: 16),
                        ],
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _warning = true),
                        child: Text('Preview form alert', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_warning)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.popover,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.qualityWarn.withValues(alpha: 0.4)),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.qualityWarn.withValues(alpha: 0.1)),
                      child: const Icon(Icons.warning_amber_rounded, color: AppColors.qualityWarn, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FORM IS DRIFTING', style: eyebrowStyle(size: 10)),
                              GestureDetector(
                                onTap: () => setState(() => _warning = false),
                                child: const Icon(Icons.close, size: 16, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your range dropped 12%. Keep your chest tall\u2014you're close. Two strong reps left.",
                            style: AppText.sans(size: 12, color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
