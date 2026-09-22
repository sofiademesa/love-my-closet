import 'package:flutter/material.dart';

import '../../theme.dart';
import 'onboarding_slide.dart';

/// Onboarding 1: closet doors + "nothing to wear" headline.
class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      eyebrow: 'SOUND FAMILIAR?',
      headline: 'When \u2018nothing to wear\u2019 is your daily problem...',
      illustration: (width, height) => _ClosetDoors(width: width, height: height),
    );
  }
}

class _ClosetDoors extends StatelessWidget {
  const _ClosetDoors({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      label: 'Closed closet doors',
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonPink.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.softPink, AppColors.buttonPink],
                ),
              ),
              child: Stack(
                children: [
                  // Glossy highlight across the top of the doors.
                  Positioned(
                    top: -height * 0.28,
                    left: -width * 0.15,
                    right: -width * 0.15,
                    child: Container(
                      height: height * 0.55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  // Seam between the two doors, with a grooved look.
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 1,
                            color: AppColors.mutedBrown.withValues(alpha: 0.18),
                          ),
                          Container(
                            width: 1,
                            color: AppColors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Two small handles either side of the seam.
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _handle(),
                        const SizedBox(width: Spacing.sm),
                        _handle(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Container(
      width: 5,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedBrown.withValues(alpha: 0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}