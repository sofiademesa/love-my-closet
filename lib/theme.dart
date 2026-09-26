// lib/theme.dart
import 'package:flutter/material.dart';

import 'data/accessibility_store.dart';

/// 1. Palette ---------------------------------------------------------------
class AppColors {
  static bool get _hc => AccessibilityStore.instance.highContrast;

  // Text/accent colors switch to a deeper, calmer shade when High Contrast
  // is on — never lighter/brighter, so nothing clips to a neon look.
  // Backgrounds (cream, white, butterYellow) are left alone on purpose: the
  // goal is more legible text and borders, not a different-looking app.
  static Color get softPink =>
      _hc ? const Color(0xFFDD6AA3) : const Color(0xFFFF8EC0); // Primary Soft Pink: active states, primary UI elements
  static Color get hotPink =>
      _hc ? const Color(0xFFB8175F) : const Color(0xFFEE3E91); // Title Hot Pink: screen titles, headings
  static const butterYellow = Color(0xFFFFE78C); // Secondary Butter Yellow: highlights, secondary actions
  static const cream = Color(0xFFFFF8F2); // Background Warm Cream: app background
  static Color get blush =>
      _hc ? const Color(0xFFD98FB3) : const Color(0xFFFAD7E7); // Stroke Soft Blush: borders, dividers
  static Color get mutedBrown =>
      _hc ? const Color(0xFF3D2B34) : const Color(0xFF76596A); // Text Muted Brown: body text, labels
  static Color get errorRed =>
      _hc ? const Color(0xFF7A150F) : const Color(0xFFB3261E); // Error Red: error messages
  static const white = Color(0xFFFFFFFF); // White: text/icons on colored buttons

  /// Button fill that passes contrast with white text (3.25:1, bold 18.7px+).
  static Color get buttonPink =>
      _hc ? const Color(0xFFC21C74) : const Color(0xFFE95B9F);

  /// Deep maroon-pink outline used for the bottom nav bar's border.
  static Color get navBorder =>
      _hc ? const Color(0xFF7A1F44) : const Color(0xFFC3356F);
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

/// Soft, on-brand shadows used to lift surfaces (cards, buttons, the nav
/// bar) off the dotted background so the UI reads as layered rather than flat.
class AppShadows {
  /// Neutral shadow for white/cream surfaces (cards, tiles, the nav bar).
  static List<BoxShadow> surface = [
    BoxShadow(
      color: AppColors.mutedBrown.withValues(alpha: 0.10),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  /// Tinted glow used under colored, tappable elements (primary buttons, FAB).
  static List<BoxShadow> glow(Color color, {double alpha = 0.35}) => [
    BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

/// 2. Type scale ------------------------------------------------------------
/// Fonts: Young Serif (headings), DM Sans (body, caption).
/// Declared under `flutter: fonts:` in pubspec.yaml.
const _headingFont = 'YoungSerif';
const _bodyFont = 'DMSans';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: _bodyFont,
  scaffoldBackgroundColor: AppColors.cream,
  colorScheme: ColorScheme(
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
  textTheme: TextTheme(
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
  cardTheme: CardThemeData(
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
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.mutedBrown,
    contentTextStyle: TextStyle(
      fontFamily: _bodyFont,
      fontSize: 14,
      color: AppColors.white,
    ),
  ),
);