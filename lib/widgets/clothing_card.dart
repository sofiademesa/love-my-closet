import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'tag_chip.dart';

/// A single wardrobe item in a grid: a big photo, name + favorite heart,
/// up to two tinted tags, and — on Closet, where [onEdit]/[onDelete] are
/// supplied — quick Edit/Delete pills. Used on Home's "More Hidden Gems"
/// (no heart, no edit/delete) and on the Closet grid (all three).
class ClothingCard extends StatelessWidget {
  const ClothingCard({
    super.key,
    required this.name,
    required this.tags,
    this.icon = Icons.checkroom_rounded,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onEdit,
    this.onDelete,
  });

  final String name;
  final List<String> tags;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const _tints = [TagChipTint.pink, TagChipTint.yellow];

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
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1.35,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      child: ClothingThumb(icon: icon, size: double.infinity, iconSize: 40),
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
                        _FavoriteHeart(active: isFavorite, onTap: onFavoriteToggle!),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      for (var i = 0; i < tags.length; i++)
                        TagChip(label: tags[i], tint: _tints[i % _tints.length]),
                    ],
                  ),
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        if (onEdit != null)
                          Expanded(child: _ActionPill.edit(onTap: onEdit!)),
                        if (onEdit != null && onDelete != null)
                          const SizedBox(width: Spacing.xs),
                        if (onDelete != null)
                          Expanded(child: _ActionPill.delete(onTap: onDelete!)),
                      ],
                    ),
                  ],
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

/// Tiny pill button used for the Edit/Delete quick actions on a Closet
/// tile — yellow with a pencil for Edit, blush with a trash can for Delete.
class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  factory _ActionPill.edit({required VoidCallback onTap}) => _ActionPill(
        label: 'edit',
        icon: Icons.edit_rounded,
        background: AppColors.butterYellow.withValues(alpha: 0.65),
        foreground: AppColors.mutedBrown,
        onTap: onTap,
      );

  factory _ActionPill.delete({required VoidCallback onTap}) => _ActionPill(
        label: 'delete',
        icon: Icons.delete_rounded,
        background: AppColors.blush,
        foreground: AppColors.errorRed,
        onTap: onTap,
      );

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: foreground),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}