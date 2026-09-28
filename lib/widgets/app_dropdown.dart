import 'package:flutter/material.dart';

import '../theme.dart';

/// Labeled dropdown field, styled to match [AppTextField]. Used for
/// Category and Color on Add Clothes / Edit Item / Save This Look / Profile.
///
/// Pass [itemLeadingBuilder] to show a small leading widget (e.g. a color
/// swatch) beside each option. That also switches on the soft menu styling:
/// rounded options, a pale-pink highlight and a checkmark on the selected
/// row instead of Flutter's default gray. Without it the dropdown looks and
/// behaves exactly as before.
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLeadingBuilder,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  /// Builds the leading widget (such as a color swatch) for an option.
  final Widget Function(String item)? itemLeadingBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium!;
    final leading = itemLeadingBuilder;
    final styled = leading != null;

    final hint = Text(
      'Select $label',
      style: body.copyWith(color: AppColors.mutedBrown.withValues(alpha: 0.55)),
    );
    final icon = Icon(
      Icons.keyboard_arrow_down_rounded,
      color: AppColors.mutedBrown,
    );

    Widget dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: hint,
        icon: icon,
        style: body,
        dropdownColor: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.field),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item,
              child: styled
                  ? _SoftOption(
                      label: item,
                      leading: leading(item),
                      selected: item == value,
                    )
                  : Text(item),
            ),
        ],
        onChanged: onChanged,
        // Styled mode only: swatch + name in the closed field, and a menu
        // that lines up with the field instead of sitting inset from it.
        selectedItemBuilder: styled
            ? (context) => [
                  for (final item in items)
                    Row(
                      children: [
                        leading(item),
                        const SizedBox(width: Spacing.sm + Spacing.xs),
                        Expanded(
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                ]
            : null,
        padding: styled
            ? const EdgeInsets.symmetric(horizontal: Spacing.md)
            : null,
        focusColor: styled ? Colors.transparent : null,
        elevation: styled ? 4 : 8,
      ),
    );

    if (styled) {
      // The gray selected row is the theme's focus/hover color. Neutralise it
      // for this dropdown only; the pale-pink highlight is drawn by
      // [_SoftOption] instead.
      dropdown = Theme(
        data: theme.copyWith(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: AppColors.blush.withValues(alpha: 0.35),
        ),
        child: dropdown,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: body),
        const SizedBox(height: Spacing.sm),
        Container(
          padding: styled
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.blush, width: 1.5),
          ),
          child: dropdown,
        ),
      ],
    );
  }
}

/// One row in the soft-styled menu: leading widget, label, and — when
/// selected — a pale-pink rounded highlight with a checkmark.
class _SoftOption extends StatelessWidget {
  const _SoftOption({
    required this.label,
    required this.leading,
    required this.selected,
  });

  final String label;
  final Widget leading;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + Spacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.blush.withValues(alpha: 0.45) : null,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: Spacing.sm + Spacing.xs),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: selected
                    ? const TextStyle(fontWeight: FontWeight.w500)
                    : null,
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 20, color: AppColors.buttonPink),
          ],
        ),
      ),
    );
  }
}