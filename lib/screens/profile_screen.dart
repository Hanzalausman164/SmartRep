import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';

/// Matches `ProfileScreen`: identity header, personal baseline metrics grid,
/// a 30-day progress sparkline, and the bottom tab bar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.go});
  final GoTo go;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: 'Profile', action: const Icon(Icons.refresh, size: 18)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary),
                        child: Text('MU', style: AppText.display(size: 22, weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Muhammad Umar', style: AppText.display(size: 24, weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Age 22 \u00b7 +92 300 1234567', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.check, size: 12, color: AppColors.qualityGood),
                                const SizedBox(width: 4),
                                Text('BASELINE CALIBRATED', style: eyebrowStyle(size: 9, color: AppColors.qualityGood)),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                          Text('PERSONAL BASELINE', style: eyebrowStyle()),
                          TextButton(
                            onPressed: () => go(AppScreen.calibration),
                            child: Text('Recalibrate', style: AppText.sans(size: 10, weight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        childAspectRatio: 1.7,
                        children: const [
                          MetricTile(label: 'ROM range', value: '48\u201392', suffix: 'cm'),
                          MetricTile(label: 'Ideal speed', value: '0.8\u20131.2', suffix: 'm/s'),
                          MetricTile(label: 'Top pause', value: '0.7\u20131.1', suffix: 'sec'),
                          MetricTile(label: 'Confidence', value: '94', suffix: '%'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('30-DAY PROGRESS', style: eyebrowStyle()),
                              const SizedBox(height: 4),
                              Text('Average rep quality', style: AppText.sans(size: 10, color: AppColors.mutedForeground)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+12.8%', style: AppText.display(size: 20, weight: FontWeight.w700, color: AppColors.qualityGood)),
                              Text('IMPROVEMENT', style: eyebrowStyle(size: 9)),
                            ],
                          ),
                        ],
                      ),
                      const Sparkline(values: [55, 58, 61, 64, 72, 70, 81, 86]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lat Pulldown', style: AppText.sans(size: 13, weight: FontWeight.w600)),
                            Text('Most trained \u00b7 8 sessions', style: AppText.sans(size: 10, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedForeground),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        BottomNav(
          active: 'profile',
          onTap: (id) {
            switch (id) {
              case 'progress':
                go(AppScreen.summary);
              case 'scan':
                go(AppScreen.scan);
              default:
                go(AppScreen.profile);
            }
          },
        ),
      ],
    );
  }
}
