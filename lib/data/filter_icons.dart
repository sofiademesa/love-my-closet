import 'package:flutter/material.dart';

import '../widgets/filter_chips.dart';

/// Wraps a plain Material glyph as a [ChipIconBuilder].
ChipIconBuilder _glyph(IconData data) {
  return (context, size, color) => Icon(data, size: size, color: color);
}

/// Wraps one of the hand-drawn category silhouettes (assets/images/icon_*.png)
/// as a [ChipIconBuilder], tinted to match the chip's active/inactive color.
ChipIconBuilder _asset(String name) {
  return (context, size, color) => ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: Image.asset(
          'assets/images/$name.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
}

/// Icon for each clothing category chip. Shared by every screen that shows
/// the category filter row (Closet, Outfit Builder) so a given label always
/// gets the same icon. The five garment categories use hand-drawn silhouettes
/// (a T-shirt, pants, a dress, a jacket, a shoe) so each icon actually reads
/// as its category rather than a generic glyph.
final Map<String, ChipIconBuilder> categoryFilterIcons = {
  'Favorites': _glyph(Icons.favorite_rounded),
  'Tops': _asset('icon_tops'),
  'Bottoms': _asset('icon_bottoms'),
  'Dresses': _asset('icon_dresses'),
  'Outerwear': _asset('icon_outerwear'),
  'Shoes': _asset('icon_shoes'),
  'Accessories': _glyph(Icons.diamond_rounded),
};

/// Icon for each occasion chip. Shared by every screen that shows the
/// occasion filter/picker row (Closet, Add Clothes, Edit Item).
final Map<String, ChipIconBuilder> occasionFilterIcons = {
  'All Occasions': _glyph(Icons.grid_view_rounded),
  'Everyday': _glyph(Icons.wb_sunny_rounded),
  'Formal': _glyph(Icons.work_rounded),
  'Party': _glyph(Icons.celebration_rounded),
};