import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder square for a clothing photo. Until real item photos exist,
/// this shows a soft blush tile with a garment icon so cards still read
/// clearly as "an item of clothing".
class ClothingThumb extends StatelessWidget {
  const ClothingThumb({
    super.key,
    this.icon = Icons.checkroom_rounded,
    this.size = 64,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Icon(icon, color: AppColors.buttonPink, size: size * 0.45),
    );
  }
}