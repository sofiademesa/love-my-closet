import 'package:flutter/material.dart';

import '../theme.dart';

/// Main call-to-action button: a soft pink gradient fill, white bold label,
/// and a tinted glow that lifts it off the page.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 42,
    this.fontSize = 18.7,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Button height and label size. Defaults match the original full-size
  /// CTA; pass smaller values for a quieter button next to other actions
  /// (e.g. the Wear Me card, where "Style This" sits beside "Skip").
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.button);
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: enabled ? AppShadows.glow(AppColors.buttonPink) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: enabled
                  ? [AppColors.softPink, AppColors.buttonPink]
                  : [
                      AppColors.buttonPink.withValues(alpha: 0.4),
                      AppColors.buttonPink.withValues(alpha: 0.4),
                    ],
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            splashColor: AppColors.white.withValues(alpha: 0.18),
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: height,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}