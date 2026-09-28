import 'package:flutter/material.dart';

import '../animations/app_motion.dart';
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
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.softPink, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.field),
                child: ClothingThumb(icon: icon, size: 96, iconSize: 42),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You haven't worn this in $daysUnworn days",
                        style: textTheme.labelSmall!.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          PressableScale(
            enabled: onWearAgain != null,
            child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: onWearAgain == null
                  ? null
                  : AppShadows.glow(AppColors.buttonPink, alpha: 0.3),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onWearAgain,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                icon: const Icon(Icons.replay_rounded, size: 17),
                label: const Text('Wear Again'),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}