import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder square for a clothing photo. Until real item photos exist,
/// this shows a soft blush-to-pink gradient tile with a garment icon so
/// cards still read clearly as "an item of clothing".
class ClothingThumb extends StatelessWidget {
  const ClothingThumb({
    super.key,
    this.icon = Icons.checkroom_rounded,
    this.size = 64,
    this.iconSize,
  });

  final IconData icon;
  final double size;

  /// Icon size to use instead of the `size * 0.45` default. Required
  /// whenever [size] is [double.infinity] (e.g. filling an [AspectRatio]),
  /// since that default would otherwise itself be infinite.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    assert(
      size.isFinite || iconSize != null,
      'ClothingThumb: pass iconSize when size is not finite.',
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blush.withValues(alpha: 0.75),
            AppColors.softPink.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Center(
        child: Icon(
          icon,
          color: AppColors.white.withValues(alpha: 0.85),
          size: iconSize ?? size * 0.45,
        ),
      ),
    );
  }
}