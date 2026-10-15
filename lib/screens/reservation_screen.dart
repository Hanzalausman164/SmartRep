import 'package:flutter/material.dart';

import '../app_root.dart';
import '../models/machine.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `ReservationScreen`: machine info card, set/rep planning
/// steppers, a planned-volume summary, and a reserve action.
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key, required this.go, required this.machine});
  final GoTo go;
  final Machine machine;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _sets = 3;
  int _reps = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: widget.machine.supportsAlternating ? 'Join machine' : 'Reserve machine', onBack: () => widget.go(AppScreen.connecting)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      MachineArtwork(height: 112, width: 128, assetPath: widget.machine.asset, semanticLabel: '${widget.machine.name} machine'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.qualityGood, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(widget.machine.supportsAlternating ? 'OPEN FOR ALTERNATE REPS' : 'AVAILABLE NOW', style: eyebrowStyle(size: 10, color: widget.machine.supportsAlternating ? const Color(0xFF7DD3FC) : AppColors.qualityGood)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(widget.machine.name, style: AppText.display(size: 22, weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Station ${widget.machine.id} · ${widget.machine.floor}', style: AppText.sans(size: 11, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Plan this exercise', style: eyebrowStyle()),
                CounterStepper(label: 'Number of sets', value: _sets, min: 1, max: 8, onChanged: (v) => setState(() => _sets = v)),
                CounterStepper(label: 'Reps per set', value: _reps, min: 1, max: 30, onChanged: (v) => setState(() => _reps = v)),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.machine.supportsAlternating
                              ? 'Alternate with the current member during their rest periods.'
                              : 'This station is held for you until all $_sets sets are complete or you end the exercise.',
                          style: AppText.sans(size: 12, color: AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PLANNED VOLUME', style: eyebrowStyle(size: 9)),
                        Text('${_sets * _reps} REPS', style: AppText.display(size: 26, weight: FontWeight.w700)),
                      ],
                    ),
                    Text('\u2248 ${_sets * 2} min', style: AppText.sans(size: 12, color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  onPressed: () => widget.go(AppScreen.calibration),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(widget.machine.supportsAlternating ? 'Join & continue' : 'Reserve & continue'), SizedBox(width: 6), Icon(Icons.chevron_right, size: 16)],
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
