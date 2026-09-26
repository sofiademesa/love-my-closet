import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';
import '../theme.dart';

/// Onboarding progress indicator: the current step is a pill, the rest are dots.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: kMotionDuration(const Duration(milliseconds: 250)),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
            color: i == current ? AppColors.buttonPink : AppColors.softPink.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(4),
            boxShadow: i == current
             ? [
                      BoxShadow(
                        color: AppColors.buttonPink.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
      ],
    );
  }
}