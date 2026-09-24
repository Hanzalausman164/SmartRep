import 'package:flutter/material.dart';

/// Color palette ported from the original prototype's oklch design tokens
/// (`src/styles.css` in the web source) to plain Flutter [Color]s.
class AppColors {
  AppColors._();

  static const background = Color(0xFF141414);
  static const foreground = Color(0xFFF7F7F7);
  static const card = Color(0xFF1F1F1F);
  static const popover = Color(0xFF242424);
  static const secondary = Color(0xFF2B2B2B);
  static const mutedForeground = Color(0xFFA8A8A8);
  static const accent = Color(0xFF2F2F2F);
  static const border = Color(0xFF3A3A3A);
  static const stage = Color(0xFF0E0E0E);
  static const camera = Color(0xFF242424);

  /// Bluetooth / brand accent, matches `.bluetooth-signal { color: #2196f3 }`.
  static const brandBlue = Color(0xFF2196F3);

  static const qualityGood = Color(0xFF4CC98A);
  static const qualityWarn = Color(0xFFE0B23D);
  static const qualityPoor = Color(0xFFE05A54);
}
