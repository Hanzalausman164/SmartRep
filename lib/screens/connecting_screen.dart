import 'dart:async';

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `ConnectingScreen`: BLE pairing status, machine info card, and a
/// "Start lifting" action that unlocks once the simulated pairing completes.
class ConnectingScreen extends StatefulWidget {
  const ConnectingScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<ConnectingScreen> createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen> {
  bool _connected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _connected = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: 'Bluetooth pairing', onBack: () => widget.go(AppScreen.scan)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _connected ? AppColors.qualityGood.withValues(alpha: 0.1) : AppColors.card,
                    border: Border.all(color: _connected ? AppColors.qualityGood : AppColors.border),
                  ),
                  child: Icon(
                    _connected ? Icons.check : Icons.bluetooth,
                    size: 36,
                    color: _connected ? AppColors.qualityGood : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _connected ? 'Sensor stream live' : 'Connecting to SR-LP-014',
                  style: eyebrowStyle(size: 11, color: _connected ? AppColors.qualityGood : AppColors.mutedForeground),
                ),
                const SizedBox(height: 6),
                Text(_connected ? 'Lat Pulldown' : 'Hold steady', style: AppText.display(size: 26, weight: FontWeight.w700)),
                const SizedBox(height: 16),
                const MachineArtwork(height: 200),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      StatItem(label: 'Signal', value: '\u221242 dBm'),
                      StatItem(label: 'Sensor', value: 'Hall + IMU'),
                      StatItem(label: 'Battery', value: '84%'),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),
                Text(
                  'Cable resistance machine for controlled vertical pulling. Targets the lats, upper back, and biceps.',
                  style: AppText.sans(size: 13, color: AppColors.mutedForeground),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _connected ? () => widget.go(AppScreen.reservation) : null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Start lifting'), SizedBox(width: 6), Icon(Icons.chevron_right, size: 16)],
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
