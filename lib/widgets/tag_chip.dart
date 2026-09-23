import 'package:flutter/material.dart';

import '../theme.dart';

/// Which fill a [TagChip] uses. Defaults to [neutral] (the low-key blush
/// pill used on detail screens); [pink]/[yellow] give the two-tone
/// category + occasion pills seen on the Closet and Home grids.
enum TagChipTint { neutral, pink, yellow }

/// Small pill used to label an item's type or occasion (e.g. "Tops",
/// "Casual") on item cards throughout the app.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.tint = TagChipTint.neutral});

  final String label;
  final TagChipTint tint;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    switch (tint) {
      case TagChipTint.pink:
        background = AppColors.blush;
        border = AppColors.blush;
        break;
      case TagChipTint.yellow:
        background = AppColors.butterYellow.withValues(alpha: 0.55);
        border = AppColors.butterYellow;
        break;
      case TagChipTint.neutral:
        background = AppColors.blush.withValues(alpha: 0.35);
        border = AppColors.blush;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedBrown,
        ),
      ),
    );
  }
}