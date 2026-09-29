import 'package:flutter/material.dart';

import 'clothing_item.dart';

/// A closet item that's been dragged onto the Outfit Builder board, with its
/// own free-form position and size so pieces can be arranged like a flat lay.
class OutfitPiece {
  OutfitPiece({
    required this.id,
    required this.item,
    required this.offset,
    this.scale = 1,
  });

  /// Smallest and largest size a piece can be resized to, relative to its
  /// default size on the board. Matches the check on outfit_items.scale.
  static const double minScale = 0.4;
  static const double maxScale = 3.0;

  final String id;
  final ClothingItem item;

  /// Top-left corner on the board.
  Offset offset;

  /// Size relative to the default board size (1 = default).
  double scale;

  OutfitPiece copy() => OutfitPiece(id: id, item: item, offset: offset, scale: scale);
}

/// An outfit combo saved from the board, as it appears on one calendar date.
///
/// In the database this is two rows: the look itself (`outfits` +
/// `outfit_items`, identified by [outfitId]) and its entry on the Calendar
/// (`calendar_entries`, identified by [id]) which also holds the diary
/// [note]. The same look can be logged on several dates; each date is its
/// own [SavedOutfit] sharing one [outfitId].
class SavedOutfit {
  const SavedOutfit({
    required this.id,
    required this.outfitId,
    required this.name,
    required this.date,
    required this.pieces,
    this.note,
  });

  /// Calendar entry id.
  final String id;

  /// The saved look this entry shows.
  final String outfitId;
  final String name;
  final DateTime date;
  final List<OutfitPiece> pieces;

  /// Optional "how did today's look feel?" diary note.
  final String? note;

  SavedOutfit copyWith({
    String? name,
    DateTime? date,
    List<OutfitPiece>? pieces,
    String? note,
  }) {
    return SavedOutfit(
      id: id,
      outfitId: outfitId,
      name: name ?? this.name,
      date: date ?? this.date,
      pieces: pieces ?? this.pieces,
      note: note ?? this.note,
    );
  }
}