import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_thumb.dart';
import 'tag_chip.dart';

/// A single wardrobe item in a grid: photo, name, and up to two tags.
/// Used by the "More Hidden Gems" section on Home.
class ClothingCard extends StatelessWidget {
  const ClothingCard({
    super.key,
    required this.name,
    required this.tags,
    this.icon = Icons.checkroom_rounded,
    this.onTap,
  });

  final String name;
  final List<String> tags;
  final IconData icon;
  final VoidCallback? onTap;

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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: ClothingThumb(icon: icon, size: 72)),
                  const SizedBox(height: Spacing.sm),
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
      );
    }
  }