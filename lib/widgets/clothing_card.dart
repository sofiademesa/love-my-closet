import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';

/// A single wardrobe item in a grid: a big photo and a name + favorite
/// heart row. On Closet, where [onEdit]/[onDelete] are supplied, a small
/// "more" button sits over the top-right corner of the photo, right-
/// aligned with the heart below, and reveals Edit/Delete in a menu so
/// those actions stay out of the way until wanted. Used on Home's "More
/// Hidden Gems" (no heart, no menu) and on the Closet grid (both).
class ClothingCard extends StatelessWidget {
  const ClothingCard({
    super.key,
    required this.name,
    this.icon = Icons.checkroom_rounded,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardRadius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: cardRadius,
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.sm, Spacing.sm, Spacing.sm, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1.35,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.field),
                            child:
                                ClothingThumb(icon: icon, size: double.infinity, iconSize: 40),
                          ),
                        ),
                        // Right-aligned with the favorite heart below, so
                        // the two quiet actions read as one column instead
                        // of the menu floating anywhere on the photo.
                        if (onEdit != null || onDelete != null)
                          Positioned(
                            top: 4,
                            right: 6,
                            child: _CardMenuButton(onEdit: onEdit, onDelete: onDelete),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        // Nudged in from the card's edge, in from the
                        // same amount as the "more" circle above, so the
                        // two sit in one column instead of hugging it.
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _FavoriteHeart(
                            active: isFavorite,
                            onTap: onFavoriteToggle!,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small heart toggle next to a [ClothingCard]'s name, so favoriting
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
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: active ? AppColors.buttonPink : AppColors.mutedBrown,
          ),
        ),
      ),
    );
  }
}

/// Small "more" button overlaid on a [ClothingCard]'s photo, right-aligned
/// with the favorite heart in the row below. Sits on a soft translucent
/// backdrop so it stays legible over any thumbnail without shouting for
/// attention, and opens a menu with Edit/Delete instead of showing them
/// as standing buttons.
class _CardMenuButton extends StatelessWidget {
  const _CardMenuButton({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const _size = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: PopupMenuButton<VoidCallback>(
        tooltip: 'More options',
        padding: EdgeInsets.zero,
        splashRadius: _size / 2,
        offset: const Offset(0, _size),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
        color: AppColors.white,
        icon: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.cream.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.mutedBrown),
        ),
        onSelected: (action) => action(),
        itemBuilder: (context) => [
          if (onEdit != null)
            PopupMenuItem<VoidCallback>(
              value: onEdit,
              height: 40,
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 17, color: AppColors.mutedBrown),
                  const SizedBox(width: Spacing.sm),
                  const Text('Edit'),
                ],
              ),
            ),
          if (onDelete != null)
            PopupMenuItem<VoidCallback>(
              value: onDelete,
              height: 40,
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 17, color: AppColors.errorRed),
                  const SizedBox(width: Spacing.sm),
                  Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}