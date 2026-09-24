import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';

/// Matches `SummaryScreen`: headline stats, a ROM/tempo sparkline, a rep
/// quality bar, and a short coach insight.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.go});
  final GoTo go;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: 'Session summary', action: const Icon(Icons.share, size: 18)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WORKOUT COMPLETE', style: eyebrowStyle(color: AppColors.qualityGood)),
                      const SizedBox(height: 6),
                      Text('Strong finish.', style: AppText.display(size: 36, weight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Lat Pulldown \u00b7 6 min 42 sec', style: AppText.sans(size: 12, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _BigStat(value: '30', label: 'Total reps'),
                      _BigStat(value: '3/3', label: 'Sets'),
                      _BigStat(value: '87', label: 'Quality'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ROM & TEMPO TREND', style: eyebrowStyle()),
                          Text('+6.4% TODAY', style: AppText.sans(size: 10, weight: FontWeight.w700, color: AppColors.qualityGood)),
                        ],
                      ),
                      const Sparkline(values: [62, 70, 66, 76, 82, 79, 88, 91]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SET 1', style: eyebrowStyle(size: 9)),
                          Text('SET 2', style: eyebrowStyle(size: 9)),
                          Text('SET 3', style: eyebrowStyle(size: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REP QUALITY', style: eyebrowStyle()),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: [
                              Expanded(flex: 73, child: Container(color: AppColors.qualityGood)),
                              Expanded(flex: 20, child: Container(color: AppColors.qualityWarn)),
                              Expanded(flex: 7, child: Container(color: AppColors.qualityPoor)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _QualityLabel(count: '22', label: 'good', color: AppColors.qualityGood),
                          _QualityLabel(count: '6', label: 'moderate', color: AppColors.qualityWarn),
                          _QualityLabel(count: '2', label: 'poor', color: AppColors.qualityPoor),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: AppColors.qualityGood),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('COACH INSIGHT', style: eyebrowStyle()),
                            const SizedBox(height: 4),
                            Text(
                              'Your tempo stayed consistent. Fatigue appeared at rep 7 in set 2, but you recovered after rest.',
                              style: AppText.sans(size: 12, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  onPressed: () => go(AppScreen.profile),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Done'), SizedBox(width: 8), Icon(Icons.check, size: 16)],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppText.display(size: 28, weight: FontWeight.w700)),
        Text(label.toUpperCase(), style: eyebrowStyle(size: 9)),
      ],
    );
  }
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel({required this.count, required this.label, required this.color});
  final String count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppText.sans(size: 11, color: AppColors.foreground),
        children: [
          TextSpan(text: '$count ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          TextSpan(text: label),
        ],
      ),
    );
  }
}
