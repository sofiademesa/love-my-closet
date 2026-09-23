import 'package:flutter/material.dart';

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
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            _Chip(
              label: option,
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
  });

  final String label;
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
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
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.white : AppColors.mutedBrown,
            ),
          ),
        ),
      ),
    );
  }
}