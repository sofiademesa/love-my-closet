import 'package:flutter/material.dart';

import '../../theme.dart';
import 'onboarding_slide.dart';

/// Onboarding 1: closet doors + "nothing to wear" headline.
class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      headline: 'When ‘nothing to wear’ is your daily problem...',
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
    return Semantics(
      label: 'Closed closet doors',
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.buttonPink,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Stack(
            children: [
              // Seam between the two doors.
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 1.5,
                    color: AppColors.white.withValues(alpha: 0.35),
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
    );
  }

  Widget _handle() {
    return Container(
      width: 5,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}