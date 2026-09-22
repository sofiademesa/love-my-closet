import 'package:flutter/material.dart';

import '../theme.dart';

/// Small pink outline pill used to label an item's type or occasion
/// (e.g. "Top", "Casual") on item cards throughout the app.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softPink, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.hotPink,
        ),
      ),
    );
  }
}