import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'dot_pattern.dart';
import 'primary_button.dart';

/// The "Hidden Gem of the Day" spotlight card in the Wear Me section:
/// one suggested item with a big photo and a single "Style Me" action.
class WearMeCard extends StatelessWidget {
  const WearMeCard({
    super.key,
    required this.name,
    required this.daysUnworn,
    this.icon = Icons.checkroom_rounded,
    this.onStyleThis,
    this.imageUrl,
    this.backgroundColorName,
  });

  final String name;
  final int daysUnworn;
  final IconData icon;
  final VoidCallback? onStyleThis;
  final String? imageUrl;

  /// The item's Color, shown behind the photo.
  final String? backgroundColorName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final cardRadius = BorderRadius.circular(AppRadius.card);

    return Container(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: DotPattern(
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hidden Gem of the Day',
                  style: textTheme.headlineSmall!.copyWith(fontSize: 16),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClothingThumb(
                      icon: icon,
                      size: 140,
                      imageUrl: imageUrl,
                      backgroundColorName: backgroundColorName,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Unworn for $daysUnworn days',
                            style: textTheme.labelSmall!.copyWith(
                              color: AppColors.mutedBrown.withValues(
                                alpha: 0.7,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                PrimaryButton(
                  label: 'Style Me',
                  onPressed: onStyleThis,
                  height: 40,
                  fontSize: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}