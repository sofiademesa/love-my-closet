import 'package:flutter/material.dart';

import '../theme.dart';

/// Labeled dropdown field, styled to match [AppTextField]. Used for
/// Category and Color on Add Clothes / Edit Item / Save This Look / Profile.
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: body),
        const SizedBox(height: Spacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.blush, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: body.copyWith(
                  color: AppColors.mutedBrown.withValues(alpha: 0.55),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.mutedBrown,
              ),
              style: body,
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.field),
              items: [
                for (final item in items)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}