import 'package:flutter/material.dart';

import '../theme.dart';

/// By default it shows [label] above the field (as in the design system
/// sheet). The onboarding screens use the compact style from the mockup:
/// set `showLabel: false` and the label becomes the placeholder inside the
/// field, next to an optional [prefixIcon].
class AppTextField extends StatefulWidget {
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
    this.onSuffixTap,
    this.suffixTooltip,
    this.maxLines = 1,
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

  /// Makes [suffixIcon] its own button (e.g. an "x" that clears a date)
  /// instead of a plain decoration.
  final VoidCallback? onSuffixTap;
  final String? suffixTooltip;

  /// Line count for multi-line fields (e.g. the "Note" box on Log Outfit).
  /// Defaults to a single line.
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  /// Only used when [AppTextField.obscureText] is true (password fields):
  /// the eye icon flips this so people can check what they typed.
  late bool _hidden = widget.obscureText;

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
    final w = widget;

    // Password fields get an eye button to show / hide what was typed.
    final Widget? suffix = w.obscureText
        ? IconButton(
            tooltip: _hidden ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _hidden = !_hidden),
            icon: Icon(
              // Shows the current state: crossed-out eye while hidden,
              // open eye once the password is visible.
              _hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mutedBrown,
              size: 20,
            ),
          )
        : (w.suffixIcon == null
            ? null
            : (w.onSuffixTap == null
                ? Icon(w.suffixIcon, color: AppColors.mutedBrown, size: 20)
                : IconButton(
                    tooltip: w.suffixTooltip,
                    onPressed: w.onSuffixTap,
                    icon: Icon(w.suffixIcon, color: AppColors.mutedBrown, size: 20),
                  )));

    final field = TextFormField(
      controller: w.controller,
      obscureText: w.obscureText && _hidden,
      keyboardType: w.keyboardType,
      textInputAction: w.textInputAction,
      validator: w.validator,
      onFieldSubmitted: w.onFieldSubmitted,
      readOnly: w.readOnly,
      onTap: w.onTap,
      maxLines: w.obscureText ? 1 : w.maxLines,
      textAlignVertical: w.maxLines > 1 ? TextAlignVertical.top : null,
      style: body,
      cursorColor: AppColors.buttonPink,
      decoration: InputDecoration(
        hintText: w.hintText ?? (w.showLabel ? null : w.label),
        hintStyle: body.copyWith(
          color: AppColors.mutedBrown.withValues(alpha: 0.6),
        ),
        prefixIcon: w.prefixIcon == null
            ? null
            : Icon(w.prefixIcon, color: AppColors.mutedBrown, size: 20),
        suffixIcon: suffix,
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

    if (!w.showLabel) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(w.label, style: body),
        const SizedBox(height: Spacing.sm),
        field,
      ],
    );
  }
}