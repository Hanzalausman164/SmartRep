import 'dart:async';

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../models/machine.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `ConnectingScreen`: BLE pairing status, machine info card, and a
/// "Start lifting" action that unlocks once the simulated pairing completes.
class ConnectingScreen extends StatefulWidget {
  const ConnectingScreen({super.key, required this.go, required this.machine});
  final GoTo go;
  final Machine machine;

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
                SizedBox(
                  width: 224, // room for the ping ring to grow (scale 2x of 112px)
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!_connected) const _PingRing(),
                      Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _connected ? AppColors.qualityGood.withValues(alpha: 0.1) : AppColors.card,
                          border: Border.all(color: _connected ? AppColors.qualityGood : AppColors.border),
                        ),
                        child: _connected
                            ? const Icon(Icons.check, size: 40, color: AppColors.qualityGood)
                            : const _PulsingIcon(Icons.bluetooth),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _connected ? 'Sensor stream live' : 'Connecting to ${widget.machine.id}',
                  style: eyebrowStyle(size: 11, color: _connected ? AppColors.qualityGood : AppColors.mutedForeground),
                ),
                const SizedBox(height: 6),
                Text(_connected ? widget.machine.name : 'Hold steady', style: AppText.display(size: 26, weight: FontWeight.w700)),
                const SizedBox(height: 16),
                MachineArtwork(height: 224, assetPath: widget.machine.asset, semanticLabel: '${widget.machine.name} machine'),
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
                  '${widget.machine.name} sensor is ready to pair. SmartRep will track your movement and rep quality in real time.',
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

/// Tailwind `animate-ping`: a 112px ring that scales 1 -> 2 while fading out (1s, loop).
class _PingRing extends StatefulWidget {
  const _PingRing();
  @override
  State<_PingRing> createState() => _PingRingState();
}

class _PingRingState extends State<_PingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  static const _curve = Cubic(0, 0, 0.2, 1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _curve.transform(_c.value);
          return Opacity(
            opacity: 1 - t,
            child: Transform.scale(
              scale: 1 + t,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mutedForeground.withValues(alpha: 0.2)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tailwind `animate-pulse`: opacity 1 -> .5 -> 1 over 2s (loop).
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon(this.icon);
  final IconData icon;
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  static const _curve = Cubic(0.4, 0, 0.6, 1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        final o = v < 0.5 ? 1 - 0.5 * _curve.transform(v / 0.5) : 0.5 + 0.5 * _curve.transform((v - 0.5) / 0.5);
        return Opacity(opacity: o, child: Icon(widget.icon, size: 40, color: AppColors.foreground));
      },
    );
  }
}
