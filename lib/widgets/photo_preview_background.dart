import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_color_dot.dart';

/// Backdrop shown BEHIND a clothing photo, for preview only.
///
/// 'Transparent' draws a checkerboard so a see-through cutout reads as
/// see-through; any other color name draws that color. This is purely a
/// widget behind the image: it is never painted into the image bytes, so the
/// processed PNG stays transparent.
class PhotoPreviewBackground extends StatelessWidget {
  const PhotoPreviewBackground({
    super.key,
    required this.colorName,
    required this.child,
  });

  final String colorName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (colorName == 'Transparent') {
      return CustomPaint(painter: const _CheckerboardPainter(), child: child);
    }
    final isMulti = colorName == 'Multicolor';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isMulti ? null : (ClothingColorDot.swatchFor(colorName) ?? AppColors.white),
        gradient: isMulti ? ClothingColorDot.multicolorGradient : null,
      ),
      child: child,
    );
  }
}

/// Transparent-background checkerboard (moved here from the photo screen so
/// the Add Clothes form and the preview screen share one look).
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 14.0;
    final light = Paint()..color = AppColors.white;
    final dark = Paint()..color = AppColors.blush.withValues(alpha: 0.6);
    canvas.drawRect(Offset.zero & size, light);
    for (double y = 0; y < size.height; y += cell) {
      for (double x = 0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()).isEven;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerboardPainter oldDelegate) => false;
}