import 'package:flutter/material.dart';

import '../models/machine.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Lists Bluetooth-enabled SmartRep stations currently in range.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.onSelect});

  final ValueChanged<Machine> onSelect;

  void _select(Machine machine) => onSelect(machine);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(title: 'Machines nearby'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR NEXT SET STARTS HERE', style: eyebrowStyle()),
                const SizedBox(height: 8),
                Text(
                  'FIND A MACHINE.',
                  style: AppText.display(size: 36, weight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a nearby station to connect.',
                  style: AppText.sans(
                    size: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      '${nearbyMachines.length} MACHINES IN RANGE',
                      style: eyebrowStyle(size: 9),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 10),
                for (final machine in nearbyMachines) ...[
                  _MachineCard(machine: machine, onTap: () => _select(machine)),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.monitor_heart_outlined,
                          size: 16,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppText.sans(
                              size: 10,
                              color: AppColors.mutedForeground,
                            ).copyWith(height: 1.5),
                            children: [
                              TextSpan(
                                text: 'OPEN FOR ALT. (ALTERNATE REPS)\n',
                                style: AppText.sans(
                                  size: 10,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text: 'means someone is resting between sets and is open to alternate reps.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _MachineCard extends StatelessWidget {
  const _MachineCard({required this.machine, required this.onTap});

  final Machine machine;
  final VoidCallback onTap;

  String get _statusLabel => switch (machine.status) {
        MachineStatus.free => 'FREE',
        MachineStatus.occupied => 'OCCUPIED',
        MachineStatus.openForAlternates => 'OPEN FOR ALT.',
      };

  Color get _statusColor => switch (machine.status) {
        MachineStatus.free => AppColors.qualityGood,
        MachineStatus.occupied => AppColors.qualityWarn,
        MachineStatus.openForAlternates => const Color(0xFF7DD3FC),
      };

  @override
  Widget build(BuildContext context) {
    final occupied = machine.status == MachineStatus.occupied;

    return Semantics(
      button: true,
      label: '${machine.name}, ${machine.id}, $_statusLabel; '
          '${occupied ? 'view status' : 'select machine'}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            height: 76,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(machine.asset, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 92),
                              child: Text(
                                machine.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.sans(
                                  size: 14,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${machine.id} · ${machine.floor}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 9,
                                      letterSpacing: 0.4,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ),
                                if (occupied)
                                  Text('DETAILS', style: eyebrowStyle(size: 9))
                                else
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: AppColors.mutedForeground,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusDot(color: _statusColor, pulse: !occupied),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel,
                          style: AppText.sans(
                            size: 9,
                            weight: FontWeight.w700,
                            color: _statusColor,
                          ).copyWith(letterSpacing: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, required this.pulse});

  final Color color;
  final bool pulse;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: 0.6 * (1 - _controller.value),
                child: Transform.scale(
                  scale: 1 + _controller.value,
                  child: child,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            child: const SizedBox.square(dimension: 6),
          ),
        ],
      ),
    );
  }
}