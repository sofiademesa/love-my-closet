import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_color_dot.dart';

/// Backdrop shown BEHIND a clothing photo, for preview only.
///
/// Draws the chosen color (White by default). This is purely a
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