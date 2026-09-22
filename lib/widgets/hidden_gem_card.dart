import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';

/// One row in the Hidden Gems list: photo, item name, how long it's gone
/// unworn, and a "Wear Again" action.
class HiddenGemCard extends StatelessWidget {
  const HiddenGemCard({
    super.key,
    required this.name,
    required this.daysUnworn,
    this.icon = Icons.checkroom_rounded,
    this.onWearAgain,
  });

  final String name;
  final int daysUnworn;
  final IconData icon;
  final VoidCallback? onWearAgain;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.softPink, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: Row(
        children: [
          ClothingThumb(icon: icon, size: 56),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You haven't worn this in $daysUnworn days",
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: onWearAgain == null
                  ? null
                  : AppShadows.glow(AppColors.buttonPink, alpha: 0.3),
              ),
              child: FilledButton(
                onPressed: onWearAgain,
                style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  textStyle: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: const Text('Wear Again'),
              ),
            ),
          ],
        ),
      );
    }
  }