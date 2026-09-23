import 'package:flutter/material.dart';

import '../theme.dart';

/// Rounded search pill shown under the screen title on Closet and the
/// "No Items Found" state. Named `AppSearchBar` (rather than `SearchBar`)
/// to avoid colliding with Flutter's own Material 3 widget of that name.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search your closet',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        color: AppColors.mutedBrown,
      ),
      cursorColor: AppColors.buttonPink,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14,
          color: AppColors.mutedBrown.withValues(alpha: 0.55),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.mutedBrown,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.blush, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.blush, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.buttonPink, width: 2),
        ),
      ),
    );
  }
}