import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `CalibrationScreen`: a 5-rep baseline capture with a progress
/// bar, a live "current phase" readout, and a completion overlay.
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int _rep = 0;
  bool get _complete => _rep >= 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(
          title: 'Personal calibration',
          onBack: () => widget.go(AppScreen.reservation),
          action: Text('1 of 1', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BASELINE SET', style: eyebrowStyle()),
                        Text(_complete ? 'Baseline ready' : '5 natural reps', style: AppText.display(size: 26, weight: FontWeight.w700)),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        style: AppText.display(size: 28, weight: FontWeight.w700),
                        children: [
                          TextSpan(text: '${_rep.clamp(0, 5)}'),
                          TextSpan(text: '/5', style: AppText.sans(size: 14, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
                    child: Stack(
                      children: [
                        Container(color: AppColors.secondary),
                        FractionallySizedBox(widthFactor: (_rep / 5).clamp(0, 1), child: Container(color: AppColors.foreground)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 260,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    children: [
                      const Positioned(left: 16, top: 16, bottom: 16, child: MachineArtwork(width: 160)),
                      if (!_complete)
                        Positioned(
                          left: 16,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT PHASE', style: eyebrowStyle(size: 9)),
                              Text('Pull \u00b7 controlled', style: AppText.sans(size: 13, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      if (_complete)
                        Positioned.fill(
                          child: Container(
                            color: AppColors.background.withValues(alpha: 0.88),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.qualityGood.withValues(alpha: 0.1)),
                                  child: const Icon(Icons.check, color: AppColors.qualityGood, size: 32),
                                ),
                                const SizedBox(height: 14),
                                Text('Personal range captured', style: AppText.sans(size: 13, weight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('Targets now adapt to your movement.', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Use a comfortable weight and your natural full range. SmartRep will learn your movement\u2014not force a generic target.',
                  style: AppText.sans(size: 13, color: AppColors.mutedForeground),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: () => setState(() {
                    if (_complete) {
                      widget.go(AppScreen.tracking);
                    } else {
                      _rep++;
                    }
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _complete
                        ? const [Text('Begin workout'), SizedBox(width: 6), Icon(Icons.chevron_right, size: 16)]
                        : const [Icon(Icons.fitness_center, size: 16), SizedBox(width: 8), Text('Log calibration rep')],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
