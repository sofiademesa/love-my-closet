import 'package:flutter/foundation.dart';

import '../models/outfit.dart';

/// Single source of truth for saved outfits, shared by the Outfit Builder
/// and the Calendar so they always show the same data.
///
/// This project has no dependency-injection or state-management package, so
/// this is a plain singleton — reached via [OutfitStore.instance] — backed
/// by [ChangeNotifier]. Any screen that stays on-screen while the list
/// changes (Builder's own "View Outfits" tab, or the Calendar underneath a
/// Log Outfit sheet) can add a listener and rebuild; screens that are
/// freshly pushed just read [all] once, since navigating to them already
/// triggers a rebuild.
class OutfitStore extends ChangeNotifier {
  OutfitStore._();

  static final OutfitStore instance = OutfitStore._();

  final List<SavedOutfit> _outfits = [];

  /// Every saved outfit, most recently saved first.
  List<SavedOutfit> get all => List.unmodifiable(_outfits);

  /// Outfits scheduled on [date] (comparing year/month/day only).
  List<SavedOutfit> onDate(DateTime date) {
    return _outfits.where((o) => isSameDay(o.date, date)).toList();
  }

  /// Every calendar date (normalized to midnight) that has at least one
  /// outfit logged, so the Calendar can mark those days with a dot.
  Set<DateTime> get datesWithOutfits => {
        for (final o in _outfits) DateTime(o.date.year, o.date.month, o.date.day),
      };

  SavedOutfit? byId(String id) {
    for (final o in _outfits) {
      if (o.id == id) return o;
    }
    return null;
  }

  void add(SavedOutfit outfit) {
    _outfits.insert(0, outfit);
    notifyListeners();
  }

  void update(SavedOutfit outfit) {
    final i = _outfits.indexWhere((o) => o.id == outfit.id);
    if (i == -1) return;
    _outfits[i] = outfit;
    notifyListeners();
  }

  void remove(String id) {
    _outfits.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}