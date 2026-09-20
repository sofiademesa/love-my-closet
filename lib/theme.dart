// lib/theme.dart
import 'package:flutter/material.dart';

/// 1. Palette ---------------------------------------------------------------
class AppColors {
  static const softPink = Color(0xFFFF8EC0); // Primary Soft Pink: active states, primary UI elements
  static const hotPink = Color(0xFFEE3E91); // Title Hot Pink: screen titles, headings
  static const butterYellow = Color(0xFFFFE78C); // Secondary Butter Yellow: highlights, secondary actions
  static const cream = Color(0xFFFFF8F2); // Background Warm Cream: app background
  static const blush = Color(0xFFFAD7E7); // Stroke Soft Blush: borders, dividers
  static const mutedBrown = Color(0xFF76596A); // Text Muted Brown: body text, labels
  static const errorRed = Color(0xFFB3261E); // Error Red: error messages
  static const white = Color(0xFFFFFFFF); // White: text/icons on colored buttons

  /// Button fill that passes contrast with white text (3.25:1, bold 18.7px+).
  static const buttonPink = Color(0xFFE95B9F);
}

/// 3. Spacing (4 px base unit) ------------------------------------------------
class Spacing {
  static const double xs = 4; // small gaps between closely related elements
  static const double sm = 8; // gaps between labels, icons, related components
  static const double md = 16; // standard spacing and screen edge padding
  static const double lg = 24; // spacing between major sections
}

/// Corner radii shared by the reusable widgets.
class AppRadius {
  static const double button = 14;
  static const double field = 16;
  static const double card = 20;
}

/// 2. Type scale ------------------------------------------------------------
/// Fonts: Young Serif (headings), DM Sans (body, caption).
/// Declared under `flutter: fonts:` in pubspec.yaml.
const _headingFont = 'YoungSerif';
const _bodyFont = 'DMSans';

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _bodyFont,
  scaffoldBackgroundColor: AppColors.cream,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.buttonPink,
    onPrimary: AppColors.white,
    secondary: AppColors.butterYellow,
    onSecondary: AppColors.mutedBrown,
    error: AppColors.errorRed,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.mutedBrown,
    outline: AppColors.blush,
  ),
  textTheme: const TextTheme(
    // Heading: screen titles and major headings
    headlineSmall: TextStyle(
      fontFamily: _headingFont,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.hotPink,
    ),
    // Body: descriptions, labels, general content
    bodyMedium: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.mutedBrown,
    ),
    // Caption: hints, timestamps, tags, supporting information
    labelSmall: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.mutedBrown,
    ),
  ),
  cardTheme: const CardThemeData(
    color: AppColors.white,
    margin: EdgeInsets.all(Spacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: AppColors.blush, width: 1.5),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      backgroundColor: AppColors.buttonPink,
      foregroundColor: AppColors.white,
      textStyle: const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 18.7,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.mutedBrown,
    contentTextStyle: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      color: AppColors.white,
    ),
  ),
);