import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text style helpers matching the web prototype's two font families:
/// Barlow Condensed for large display numbers/headings, Manrope for body/UI.
class AppText {
  AppText._();

  static TextStyle display({double size = 24, FontWeight weight = FontWeight.w700, Color? color}) {
    return GoogleFonts.barlowCondensed(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.foreground,
      height: 1.0,
    );
  }

  static TextStyle sans({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.foreground,
    );
  }
}

/// Small bold uppercase "eyebrow" label style used throughout the app
/// (section labels, status text, stat captions).
TextStyle eyebrowStyle({double size = 10, Color color = AppColors.mutedForeground, FontWeight weight = FontWeight.w700}) {
  return AppText.sans(size: size, weight: weight, color: color).copyWith(letterSpacing: 0.6);
}

ThemeData buildAppTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      surface: AppColors.background,
      onSurface: AppColors.foreground,
      primary: AppColors.foreground,
      onPrimary: AppColors.background,
      secondary: AppColors.secondary,
      onSecondary: AppColors.foreground,
      error: AppColors.qualityPoor,
    ),
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    ),
    dividerColor: AppColors.border,
    iconTheme: const IconThemeData(color: AppColors.foreground),
    splashFactory: InkRipple.splashFactory,
  );
}
