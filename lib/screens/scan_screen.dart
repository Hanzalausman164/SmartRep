import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Matches `ScanScreen`: a camera-style viewfinder with a QR target frame,
/// torch/gallery controls, and a simulated scan action.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _torch = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(title: 'Scan machine', action: const Icon(Icons.bluetooth, size: 18, color: AppColors.qualityGood)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 0.85,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.camera, borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.foreground.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code, size: 64, color: AppColors.foreground),
                        ),
                        Positioned(
                          bottom: 18,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _roundButton(Icons.flash_on, _torch, () => setState(() => _torch = !_torch)),
                              const SizedBox(width: 16),
                              _roundButton(Icons.photo_library, false, () {}),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Align the machine QR', textAlign: TextAlign.center, style: AppText.display(size: 24, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Scanning identifies the machine and securely starts Bluetooth pairing.',
                  textAlign: TextAlign.center,
                  style: AppText.sans(size: 13, color: AppColors.mutedForeground),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  onPressed: () => widget.go(AppScreen.connecting),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.camera_alt, size: 16), SizedBox(width: 8), Text('Simulate scan')],
                  ),
                ),
                TextButton(
                  onPressed: () => widget.go(AppScreen.unavailable),
                  child: Text('Preview reserved machine', style: AppText.sans(size: 12, color: AppColors.mutedForeground)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _roundButton(IconData icon, bool active, VoidCallback onTap) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: active ? AppColors.foreground : AppColors.secondary,
          foregroundColor: active ? AppColors.background : AppColors.foreground,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
