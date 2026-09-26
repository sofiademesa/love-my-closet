import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Layout shared by Onboarding 1 and 2: a soft halo behind the illustration,
/// then a centered serif headline underneath. The bottom is left free for
/// the dots and the "Next" button, which live in [OnboardingFlow].
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.illustration,
  });

  final String eyebrow;
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
            constraints.maxHeight - _bottomReserve - Spacing.lg - 150;
        if (maxArtHeight < artHeight) {
          artHeight = math.max(140.0, maxArtHeight);
          artWidth = artHeight / 1.36;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: _bottomReserve),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - _bottomReserve,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: artWidth * 1.5,
                      height: artHeight * 1.35,
                      child: Stack(
                        alignment: Alignment.center,
                        // Let the closet zoom past its slot on Onboarding 1
                        // without getting hard-clipped mid push-in.
                        clipBehavior: Clip.none,
                        children: [
                          // Soft radial halo for depth behind the illustration.
                          Container(
                            width: artWidth * 1.5,
                            height: artWidth * 1.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.softPink.withValues(alpha: 0.28),
                                  AppColors.softPink.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          illustration(artWidth, artHeight),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      eyebrow,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.hotPink,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
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
            ),
          ),
        );
      },
    );
  }
}