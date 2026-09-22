import 'package:flutter/material.dart';

import '../theme.dart';

/// Small neutral pill used to label an item's type or occasion
/// (e.g. "Top", "Casual") on item cards throughout the app. Kept
/// low-key (blush stroke, muted-brown text) so pink stays reserved
/// for headings and primary actions.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blush, width: 1),
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