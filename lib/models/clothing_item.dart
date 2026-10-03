import 'package:flutter/material.dart';

/// Category options shown in the Category dropdown on Add Clothes / Edit Item.
const clothingCategories = [
  'Tops',
  'Bottoms',
  'Dresses',
  'Outerwear',
  'Shoes',
  'Accessories',
];

/// Color options shown in the Color dropdown on Add Clothes / Edit Item.
const clothingColors = [
  'Pink',
  'Yellow',
  'Blue',
  'Denim',
  'White',
  'Black',
  'Multicolor',
];

/// Default Color for new items and the fallback for anything unrecognised.
const defaultClothingColor = 'White';

/// Maps a stored color to one that is still offered. Items saved before
/// 'Transparent' was removed (or any unknown value) become White, so the
/// Color dropdown never receives a value that isn't in its list.
String normalizeClothingColor(String? name) =>
    name != null && clothingColors.contains(name) ? name : defaultClothingColor;

/// Occasion tags used by the Occasion Tags chip picker, matching the design
/// system's FilterChips component.
const occasionTags = ['Everyday', 'Formal', 'Party'];

/// A single wardrobe item in the user's Digital Closet, as stored in the
/// `clothing_items` table. [timesWorn], [lastWorn] and [daysUnworn] are not
/// stored: they are worked out from the Calendar (see ClosetStore), so they
/// can never drift out of sync with what was actually logged.
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.occasion,
    this.daysUnworn = 0,
    this.icon = Icons.checkroom_rounded,
    this.color = defaultClothingColor,
    this.isFavorite = false,
    this.timesWorn = 0,
    this.lastWorn,
    this.imagePath,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String occasion;
  final int daysUnworn;
  final IconData icon;
  final String color;

  /// The heart on the item tile / detail screen; drives the "Favorites"
  /// filter chip on Closet and Outfit Builder.
  final bool isFavorite;

  /// How many times this item has been logged as worn.
  final int timesWorn;

  /// Display-formatted date (e.g. "09/03/2026") this item was last worn,
  /// or null if it has never been worn.
  final String? lastWorn;

  /// Path of the transparent PNG in the private `clothing-images` bucket.
  final String? imagePath;

  /// Short-lived signed URL for [imagePath], ready for Image.network.
  final String? imageUrl;

  ClothingItem copyWith({
    String? name,
    String? category,
    String? occasion,
    String? color,
    bool? isFavorite,
    int? daysUnworn,
    int? timesWorn,
    String? lastWorn,
    String? imagePath,
    String? imageUrl,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      occasion: occasion ?? this.occasion,
      daysUnworn: daysUnworn ?? this.daysUnworn,
      icon: icon,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWorn: lastWorn ?? this.lastWorn,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}