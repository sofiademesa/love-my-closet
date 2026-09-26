import 'package:flutter/foundation.dart';

/// The three text sizes offered on the Accessibility screen, and the scale
/// factor each applies on top of the app's normal type scale.
enum TextSizeOption { small, standard, large }

extension TextSizeOptionX on TextSizeOption {
  double get scale {
    switch (this) {
      case TextSizeOption.small:
        return 0.9;
      case TextSizeOption.standard:
        return 1.0;
      case TextSizeOption.large:
        return 1.15;
    }
  }

  String get label {
    switch (this) {
      case TextSizeOption.small:
        return 'Small';
      case TextSizeOption.standard:
        return 'Default';
      case TextSizeOption.large:
        return 'Large';
    }
  }
}

/// Single source of truth for the three Accessibility settings (Text Size,
/// Reduce Motion, High Contrast), same singleton + [ChangeNotifier] pattern
/// as [UserProfileStore] so it needs no extra state-management package.
///
/// Nothing here changes any screen's layout or content — it only changes
/// how the *existing* UI is rendered:
/// - [textSize] is read once, in `main.dart`, to scale all text app-wide via
///   a [MediaQuery] override.
/// - [highContrast] is read once, in `main.dart`, to wrap the whole app in a
///   contrast-boosting [ColorFiltered] overlay.
/// - [reduceMotion] is read by [kMotionDuration], called from every
///   `AnimatedContainer`/`AnimatedOpacity`/page-transition duration in the
///   app, to collapse that animation to zero instead of playing it.
///
/// Turning a setting back off simply stops applying the override, so the
/// app returns exactly to its default look and feel.
class AccessibilityStore extends ChangeNotifier {
  AccessibilityStore._();

  static final AccessibilityStore instance = AccessibilityStore._();

  TextSizeOption _textSize = TextSizeOption.standard;
  bool _reduceMotion = false;
  bool _highContrast = false;

  TextSizeOption get textSize => _textSize;
  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;

  void setTextSize(TextSizeOption value) {
    if (_textSize == value) return;
    _textSize = value;
    notifyListeners();
  }

  void setReduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    if (_highContrast == value) return;
    _highContrast = value;
    notifyListeners();
  }
}

/// Wrap any animation's `duration:` in this. Returns [normal] unchanged
/// unless Reduce Motion is on, in which case it returns [Duration.zero] so
/// the animation snaps to its end state instantly instead of playing.
Duration kMotionDuration(Duration normal) =>
    AccessibilityStore.instance.reduceMotion ? Duration.zero : normal;