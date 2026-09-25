import 'package:flutter/material.dart';

import 'clothing_item.dart';

/// A closet item that's been dragged onto the Outfit Builder board, with its
/// own free-form position so pieces can be arranged like a flat lay.
class OutfitPiece {
  OutfitPiece({
    required this.id,
    required this.item,
    required this.offset,
  });

  final String id;
  final ClothingItem item;
  Offset offset;

  OutfitPiece copy() => OutfitPiece(id: id, item: item, offset: offset);
}

/// An outfit combo saved from the board, shown on the "View Outfits" tab.
class SavedOutfit {
  const SavedOutfit({
    required this.id,
    required this.name,
    required this.date,
    required this.pieces,
  });

  final String id;
  final String name;
  final DateTime date;
  final List<OutfitPiece> pieces;
}