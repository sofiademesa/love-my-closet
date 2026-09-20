import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Layout shared by Onboarding 1 and 2: an illustration on top and a centered
/// serif headline underneath. The bottom is left free for the dots and the
/// "Next" button, which live in [OnboardingFlow].
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.headline,
    required this.illustration,
  });

  final String headline;

  /// Builds the artwork for the given size.
  final Widget Function(double width, double height) illustration;

  /// Space reserved at the bottom for the dots + Next button.
  static const double _bottomReserve = 128;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var artWidth = math.min(constraints.maxWidth * 0.58, 260.0);
        var artHeight = artWidth * 1.36;

        // Shrink the artwork on short screens so nothing overflows.
        final maxArtHeight =
            constraints.maxHeight - _bottomReserve - Spacing.lg - 120;
        if (maxArtHeight < artHeight) {
          artHeight = math.max(140.0, maxArtHeight);
          artWidth = artHeight / 1.36;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: _bottomReserve),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                illustration(artWidth, artHeight),
                const SizedBox(height: Spacing.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}