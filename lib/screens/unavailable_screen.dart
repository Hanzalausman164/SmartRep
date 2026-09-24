import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `UnavailableScreen`: shown when a scanned machine is already
/// reserved, with the current occupant's set progress and an ETA.
class UnavailableScreen extends StatelessWidget {
  const UnavailableScreen({super.key, required this.go});
  final GoTo go;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: 'Machine status', onBack: () => go(AppScreen.scan)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.qualityWarn.withValues(alpha: 0.1)),
                  child: const Icon(Icons.lock, size: 36, color: AppColors.qualityWarn),
                ),
                const SizedBox(height: 18),
                Text('CURRENTLY RESERVED', style: eyebrowStyle(color: AppColors.qualityWarn)),
                const SizedBox(height: 6),
                Text('Lat Pulldown', style: AppText.display(size: 30, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Station LP-014 \u00b7 Floor 01', style: AppText.sans(size: 12, color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                const MachineArtwork(height: 180, faded: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
                  ),
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
                              Text('CURRENT WORKOUT', style: eyebrowStyle(size: 9)),
                              const SizedBox(height: 4),
                              Text('Anonymous member', style: AppText.sans(size: 13, weight: FontWeight.w600)),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                              style: AppText.display(size: 24, weight: FontWeight.w700),
                              children: [const TextSpan(text: '2'), TextSpan(text: ' / 3 sets', style: AppText.sans(size: 12, color: AppColors.mutedForeground))],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: Stack(
                            children: [
                              Container(color: AppColors.secondary),
                              FractionallySizedBox(widthFactor: 2 / 3, child: Container(color: AppColors.qualityWarn)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Set 2 in progress', style: AppText.sans(size: 10, color: AppColors.mutedForeground)),
                          Text('\u2248 4 min remaining', style: AppText.sans(size: 10, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "We'll refresh availability automatically. No personal workout details are shared.",
                          style: AppText.sans(size: 12, color: AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: () => go(AppScreen.scan),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.qr_code_scanner, size: 16), SizedBox(width: 8), Text('Scan another machine')],
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
