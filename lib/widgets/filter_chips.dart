import 'package:flutter/material.dart';

import '../data/accessibility_store.dart';
import '../theme.dart';

/// Horizontally-scrolling row of single-select pills. Used for the category
/// and occasion filters on Closet and Hidden Gems, and for the Occasion Tags
/// picker on Add Clothes / Edit Item.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  /// Optional leading icon per option label — e.g. a heart on "Favorites".
  /// Options with no entry here get a plain text chip.
  final Map<String, IconData>? icons;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            _Chip(
              label: option,
              icon: icons?[option],
              active: option == selected,
              onTap: () => onSelected(option == selected ? null : option),
            ),
            const SizedBox(width: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: kMotionDuration(const Duration(milliseconds: 150)),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [AppColors.softPink, AppColors.buttonPink],
                  )
                : null,
            color: active ? null : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? Colors.transparent : AppColors.blush,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: active ? AppColors.white : AppColors.mutedBrown,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.white : AppColors.mutedBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}