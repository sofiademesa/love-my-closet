import 'package:flutter/material.dart';

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
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? AppColors.buttonPink : AppColors.softPink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}