import 'package:flutter/material.dart';

import '../theme.dart';

/// By default it shows [label] above the field (as in the design system
/// sheet). The onboarding screens use the compact style from the mockup:
/// set `showLabel: false` and the label becomes the placeholder inside the
/// field, next to an optional [prefixIcon].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.showLabel = true,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final bool showLabel;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  /// Set with [onTap] to make the field open a picker (e.g. a date picker)
  /// instead of the keyboard.
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  OutlineInputBorder _border(Color color, [double width = 1.5]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = textTheme.bodyMedium!;

    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      onTap: onTap,
      style: body,
      cursorColor: AppColors.buttonPink,
      decoration: InputDecoration(
        hintText: hintText ?? (showLabel ? null : label),
        hintStyle: body.copyWith(
          color: AppColors.mutedBrown.withValues(alpha: 0.6),
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.mutedBrown, size: 20),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: AppColors.mutedBrown, size: 20),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 14,
        ),
        enabledBorder: _border(AppColors.blush),
        focusedBorder: _border(AppColors.buttonPink, 2),
        errorBorder: _border(AppColors.errorRed),
        focusedErrorBorder: _border(AppColors.errorRed, 2),
        errorStyle: textTheme.labelSmall!.copyWith(color: AppColors.errorRed),
      ),
    );

    if (!showLabel) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: body),
        const SizedBox(height: Spacing.sm),
        field,
      ],
    );
  }
}