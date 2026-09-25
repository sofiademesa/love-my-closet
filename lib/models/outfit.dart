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

/// An outfit combo saved from the board. Shown on the Builder's "View
/// Outfits" tab and, whenever it has a [date], on the Calendar for that
/// day — both read from the same [SavedOutfit] records via `OutfitStore`,
/// so there's a single source of truth instead of separate placeholder
/// lists.
class SavedOutfit {
  const SavedOutfit({
    required this.id,
    required this.name,
    required this.date,
    required this.pieces,
    this.note,
  });

  final String id;
  final String name;
  final DateTime date;
  final List<OutfitPiece> pieces;

  /// Optional "how did today's look feel?" note, set from the Calendar's
  /// Log Outfit screen.
  final String? note;

  SavedOutfit copyWith({
    String? name,
    DateTime? date,
    List<OutfitPiece>? pieces,
    String? note,
  }) {
    return SavedOutfit(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      pieces: pieces ?? this.pieces,
      note: note ?? this.note,
    );
  }
}