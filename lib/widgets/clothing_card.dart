import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'tag_chip.dart';

/// A single wardrobe item in a grid: photo, name, and up to two tags.
/// Used on Home's "More Hidden Gems" and on the Closet grid. Pass
/// [onFavoriteToggle] to show a heart button on the tile itself (Closet);
/// leave it null to hide the heart entirely (Home).
class ClothingCard extends StatelessWidget {
  const ClothingCard({
    super.key,
    required this.name,
    required this.tags,
    this.icon = Icons.checkroom_rounded,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final String name;
  final List<String> tags;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            // The whole-card tap target lives on the bottom layer so the
            // heart (painted on top) can intercept its own taps instead of
            // also triggering this one.
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: ClothingThumb(icon: icon, size: 64)),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Wrap(
                        spacing: Spacing.xs,
                        runSpacing: Spacing.xs,
                        children: [for (final tag in tags) TagChip(label: tag)],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (onFavoriteToggle != null)
              Positioned(
                top: 4,
                right: 4,
                child: _FavoriteHeart(active: isFavorite, onTap: onFavoriteToggle!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small heart toggle overlaid on a [ClothingCard]'s corner, so favoriting
/// happens right on the tile — no separate screen or detail view needed.
class _FavoriteHeart extends StatelessWidget {
  const _FavoriteHeart({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: active ? AppColors.buttonPink : AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blush, width: 1.2),
            boxShadow: AppShadows.surface,
          ),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 14,
            color: active ? AppColors.white : AppColors.mutedBrown,
          ),
        ),
      ),
    );
  }
}