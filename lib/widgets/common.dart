import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Matches `TopBar`: optional back button, centered uppercase title, and an
/// optional trailing action, all in a fixed-height row.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.onBack, this.action});
  final String title;
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: onBack != null
                  ? IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))
                  : null,
            ),
            Expanded(
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppText.display(size: 16, weight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 44, child: action != null ? Center(child: action) : null),
          ],
        ),
      ),
    );
  }
}

/// Matches `PrimaryButton`: full-width, bold uppercase, 56px tall.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.child, this.onPressed});
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foreground,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.mutedForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppText.sans(size: 13, weight: FontWeight.w800).copyWith(letterSpacing: 0.6),
        ),
        child: child,
      ),
    );
  }
}

/// Small labeled stat, e.g. label "Signal" over value "-42 dBm".
class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: eyebrowStyle(size: 9)),
        const SizedBox(height: 4),
        Text(value, style: AppText.sans(size: 12, weight: FontWeight.w600), textAlign: TextAlign.center),
      ],
    );
  }
}

/// Matches the prototype's `Field`: an icon + text input in a card-coloured,
/// 56px-tall rounded row. Owns its controller so typing survives rebuilds;
/// if [initialValue] changes (e.g. show/hide password) the text follows.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.icon,
    required this.label,
    this.initialValue,
    this.obscure = false,
    this.suffix,
  });

  final IconData icon;
  final String label;
  final String? initialValue;
  final bool obscure;
  final Widget? suffix;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void didUpdateWidget(covariant AppField old) {
    super.didUpdateWidget(old);
    if (widget.initialValue != old.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              obscureText: widget.obscure,
              style: AppText.sans(size: 14),
              decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: widget.label),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );
  }
}

/// Matches the reservation screen's set/rep counter: a labeled +/- stepper.
class CounterStepper extends StatelessWidget {
  const CounterStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.sans(size: 14, weight: FontWeight.w600)),
          Row(
            children: [
              _stepButton(Icons.remove, () => onChanged((value - 1).clamp(min, max))),
              SizedBox(
                width: 40,
                child: Text('$value', textAlign: TextAlign.center, style: AppText.display(size: 26, weight: FontWeight.w700)),
              ),
              _stepButton(Icons.add, () => onChanged((value + 1).clamp(min, max))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.border),
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

/// Matches `Metric` on the profile screen: a small labeled stat tile.
class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, required this.suffix});
  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: eyebrowStyle(size: 9)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: AppText.display(size: 20, weight: FontWeight.w700),
              children: [
                TextSpan(text: value),
                TextSpan(text: ' $suffix', style: AppText.sans(size: 10, color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lat pulldown machine illustration (same PNG the Lovable prototype
/// imports as `lat-pulldown-clean.png`). Sized like the prototype's
/// `LatPulldown` (`object-contain`, optionally faded to 45%).
class MachineArtwork extends StatelessWidget {
  const MachineArtwork({
    super.key,
    this.faded = false,
    this.height,
    this.width,
    this.alignment = Alignment.center,
  });
  final bool faded;
  final double? height;
  final double? width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.45 : 1,
      child: Image.asset(
        'assets/images/lat-pulldown-clean.png',
        height: height,
        width: width,
        fit: BoxFit.contain,
        alignment: alignment,
        semanticLabel: 'Lat Pulldown machine',
      ),
    );
  }
}

/// Matches `BottomNav`: a 3-tab bar (Progress / Scan / Profile).
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.active, required this.onTap});
  final String active;
  final ValueChanged<String> onTap;

  static const _items = [
    (id: 'progress', label: 'Progress', icon: Icons.trending_up),
    (id: 'scan', label: 'Scan', icon: Icons.qr_code_scanner),
    (id: 'profile', label: 'Profile', icon: Icons.account_circle),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: _items.map((item) {
          final isActive = active == item.id;
          final color = isActive ? AppColors.foreground : AppColors.mutedForeground;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(item.id),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 20, color: color),
                  const SizedBox(height: 4),
                  Text(item.label, style: AppText.sans(size: 10, weight: FontWeight.w600, color: color)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
