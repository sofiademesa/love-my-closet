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

/// Occasion tags used by the Occasion Tags chip picker, matching the design
/// system's FilterChips component.
const occasionTags = ['Everyday', 'Formal', 'Party'];

/// A single wardrobe item stored in Sofia's Digital Closet.
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.occasion,
    required this.daysUnworn,
    this.icon = Icons.checkroom_rounded,
    this.color = 'Pink',
    this.isHiddenGem = false,
    this.timesWorn = 0,
    this.lastWorn,
  });

  final String id;
  final String name;
  final String category;
  final String occasion;
  final int daysUnworn;
  final IconData icon;
  final String color;
  final bool isHiddenGem;

  /// How many times this item has been logged as worn.
  final int timesWorn;

  /// Display-formatted date (e.g. "09/03/2026") this item was last worn,
  /// or null if it has never been worn.
  final String? lastWorn;

  ClothingItem copyWith({
    String? name,
    String? category,
    String? occasion,
    String? color,
    bool? isHiddenGem,
    int? timesWorn,
    String? lastWorn,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      occasion: occasion ?? this.occasion,
      daysUnworn: daysUnworn,
      icon: icon,
      color: color ?? this.color,
      isHiddenGem: isHiddenGem ?? this.isHiddenGem,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWorn: lastWorn ?? this.lastWorn,
    );
  }
}

/// Starter items so the Closet grid isn't empty on first run.
const sampleClosetItems = [
  ClothingItem(
    id: '1',
    name: 'Pink Polkadot Top',
    category: 'Tops',
    occasion: 'Everyday',
    daysUnworn: 32,
    color: 'Pink',
    timesWorn: 5,
    lastWorn: '09/03/2026',
  ),
  ClothingItem(
    id: '2',
    name: 'Yellow Bow Top',
    category: 'Tops',
    occasion: 'Everyday',
    daysUnworn: 12,
    color: 'Yellow',
    timesWorn: 3,
    lastWorn: '09/14/2026',
  ),
  ClothingItem(
    id: '3',
    name: 'Blue Tiered Skirt',
    category: 'Bottoms',
    occasion: 'Everyday',
    daysUnworn: 8,
    color: 'Blue',
    timesWorn: 7,
    lastWorn: '09/18/2026',
  ),
  ClothingItem(
    id: '4',
    name: 'Denim Skirt',
    category: 'Bottoms',
    occasion: 'Formal',
    daysUnworn: 45,
    color: 'Denim',
    timesWorn: 1,
    lastWorn: '08/12/2026',
  ),
];