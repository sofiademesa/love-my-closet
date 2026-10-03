import 'package:flutter/material.dart';

import '../theme.dart';
import 'clothing_color_dot.dart';

/// Square tile for a clothing photo: the backdrop color picked for the item
/// (the Color field on Add Clothes / Edit Item) with its transparent PNG
/// cutout on top. No color keeps the soft blush-to-pink gradient. Items without a photo (or while
/// it loads, or if it can't be fetched) show a garment icon instead, so
/// cards always read clearly as "an item of clothing".
class ClothingThumb extends StatelessWidget {
  const ClothingThumb({
    super.key,
    this.icon = Icons.checkroom_rounded,
    this.size = 64,
    this.iconSize,
    this.imageUrl,
    this.backgroundColorName,
  });

  final IconData icon;
  final double size;

  /// Icon size to use instead of the `size * 0.45` default. Required
  /// whenever [size] is [double.infinity] (e.g. filling an [AspectRatio]),
  /// since that default would otherwise itself be infinite.
  final double? iconSize;

  /// Signed URL of the item's transparent PNG (from Supabase Storage).
  final String? imageUrl;

  /// The item's Color (e.g. 'White', 'Multicolor'). Null shows
  /// the default pink gradient.
  final String? backgroundColorName;

  @override
  Widget build(BuildContext context) {
    assert(
      size.isFinite || iconSize != null,
      'ClothingThumb: pass iconSize when size is not finite.',
    );
    final url = imageUrl;
    final colorName = backgroundColorName;
    final isMulti = colorName == 'Multicolor';
    final solid = colorName == null ? null : ClothingColorDot.swatchFor(colorName);
    final useDefault = !isMulti && solid == null;
    // White icon on the pink/dark tiles, a soft brown one on light tiles.
    final lightTile = solid != null && solid.computeLuminance() > 0.6;
    final placeholder = Center(
      child: Icon(
        icon,
        color: lightTile
            ? AppColors.mutedBrown.withValues(alpha: 0.35)
            : AppColors.white.withValues(alpha: 0.85),
        size: iconSize ?? size * 0.45,
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid,
        gradient: isMulti
            ? ClothingColorDot.multicolorGradient
            : useDefault
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blush.withValues(alpha: 0.75),
                  AppColors.softPink.withValues(alpha: 0.35),
                ],
              )
            : null,
        // Keeps a White tile visible on the white cards.
        border: colorName == 'White'
            ? Border.all(color: AppColors.blush, width: 1)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: url == null
          ? placeholder
          : Padding(
              // Thin margin so the garment fills as much of the tile as it can.
              padding: EdgeInsets.all(size.isFinite ? size * 0.03 : 3),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
                errorBuilder: (context, error, stack) => placeholder,
              ),
            ),
    );
  }
}