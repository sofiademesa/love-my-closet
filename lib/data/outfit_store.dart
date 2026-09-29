import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../models/outfit.dart';
import '../services/backend_errors.dart';
import '../services/supabase_config.dart';
import 'closet_store.dart';

/// Single source of truth for saved outfits and the Calendar / Outfit Diary,
/// shared by the Outfit Builder, the Calendar, Log Outfit and Home.
///
/// Backed by three Supabase tables: `outfits` (the look), `outfit_items`
/// (which closet pieces sit where on the board) and `calendar_entries`
/// (the look on a date, with an optional diary note). Same singleton +
/// [ChangeNotifier] pattern as before, so screens that were listening keep
/// working unchanged.
class OutfitStore extends ChangeNotifier {
  OutfitStore._();

  static final OutfitStore instance = OutfitStore._();

  final Map<String, _OutfitRow> _outfits = {};
  final List<_EntryRow> _entries = [];

  bool _loading = false;
  bool _loaded = false;
  String? _error;

  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;
  String? get error => _error;

  /// Every calendar entry as a [SavedOutfit], most recently saved first.
  List<SavedOutfit> get all {
    final sorted = List.of(_entries)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [for (final e in sorted) _toSaved(e)];
  }

  /// One card per saved look for the Builder's "View Outfits" tab (a look
  /// logged on several days shows once, with its latest date). Most
  /// recently created look first.
  List<SavedOutfit> get builderOutfits {
    final latest = <String, _EntryRow>{};
    for (final e in _entries) {
      final current = latest[e.outfitId];
      if (current == null || e.wornOn.isAfter(current.wornOn)) latest[e.outfitId] = e;
    }
    final result = <SavedOutfit>[];
    final looks = _outfits.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final o in looks) {
      final entry = latest[o.id];
      result.add(
        entry != null
            ? _toSaved(entry)
            // A look without a date yet (shouldn't normally happen) still
            // shows, dated the day it was created.
            : SavedOutfit(
                id: '',
                outfitId: o.id,
                name: o.name,
                date: _dateOnly(o.createdAt.toLocal()),
                pieces: _resolvePieces(o),
              ),
      );
    }
    return result;
  }

  /// Number of distinct saved looks (Home's "Outfits" stat).
  int get outfitCount => _outfits.length;

  /// Outfits scheduled on [date] (comparing year/month/day only).
  List<SavedOutfit> onDate(DateTime date) {
    return [
      for (final e in _entries)
        if (isSameDay(e.wornOn, date)) _toSaved(e),
    ];
  }

  /// Every calendar date (normalized to midnight) that has at least one
  /// outfit logged, so the Calendar can mark those days with a dot.
  Set<DateTime> get datesWithOutfits => {for (final e in _entries) e.wornOn};

  /// Looks up a calendar entry by its id.
  SavedOutfit? byId(String id) {
    for (final e in _entries) {
      if (e.id == id) return _toSaved(e);
    }
    return null;
  }

  /// Every date (up to [upTo]) an outfit containing [clothingItemId] was
  /// logged. Used for Times Worn / Last Worn / Hidden Gems.
  List<DateTime> wornDatesFor(String clothingItemId, {required DateTime upTo}) {
    final outfitIds = {
      for (final o in _outfits.values)
        if (o.pieces.any((p) => p.clothingItemId == clothingItemId)) o.id,
    };
    if (outfitIds.isEmpty) return const [];
    return [
      for (final e in _entries)
        if (outfitIds.contains(e.outfitId) && !e.wornOn.isAfter(upTo)) e.wornOn,
    ];
  }

  // ---------------------------------------------------------------------------
  // Loading

  Future<void> load() async {
    if (!SupabaseConfig.isInitialized) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _fetch();
      _loaded = true;
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Re-reads everything quietly (no loading state).
  Future<void> refresh() async {
    if (!SupabaseConfig.isInitialized || supabase.auth.currentUser == null) return;
    try {
      await _fetch();
    } catch (e) {
      debugPrint('[Love My Closet] outfit refresh failed: $e');
    }
    notifyListeners();
  }

  /// Forget everything (on log out) so the next user never sees it.
  void clear() {
    _outfits.clear();
    _entries.clear();
    _loaded = false;
    _error = null;
    notifyListeners();
  }

  /// False once the database turns out not to have outfit_items.scale yet
  /// (supabase/migrations/20261001000000_outfit_piece_scale.sql not run),
  /// so outfits still load, just without saved sizes.
  bool _hasScaleColumn = true;

  Future<List<Map<String, dynamic>>> _selectOutfits() async {
    const base = 'id, name, created_at, outfit_items(clothing_item_id, position_x, position_y, sort_order';
    if (_hasScaleColumn) {
      try {
        return await supabase.from('outfits').select('$base, scale)');
      } on PostgrestException catch (e) {
        // 42703 = undefined column (Postgres); PGRST204 = column not found (PostgREST).
        final missingColumn =
            e.code == '42703' || e.code == 'PGRST204' || e.message.contains('scale');
        if (!missingColumn) rethrow;
        debugPrint('[Love My Closet] outfit_items.scale missing; run the '
            'outfit_piece_scale migration to save piece sizes.');
        _hasScaleColumn = false;
      }
    }
    return await supabase.from('outfits').select('$base)');
  }

  Future<void> _fetch() async {
    final List<Map<String, dynamic>> outfits = await _selectOutfits();
    final List<Map<String, dynamic>> entries = await supabase
        .from('calendar_entries')
        .select('id, outfit_id, worn_on, note, created_at');
    _outfits
      ..clear()
      ..addEntries(outfits.map((j) {
        final o = _OutfitRow.fromJson(j);
        return MapEntry(o.id, o);
      }));
    _entries
      ..clear()
      ..addAll(entries.map(_EntryRow.fromJson));
  }

  // ---------------------------------------------------------------------------
  // Changes. Each throws [BackendException] with a friendly message.

  /// Outfit Builder → "Save Outfit" / "Update Outfit". Creates (or updates)
  /// the look, its pieces and its calendar date in one transaction, and
  /// returns the saved calendar entry.
  Future<SavedOutfit> saveFromBuilder({
    String? editingEntryId,
    String? editingOutfitId,
    required String name,
    required DateTime date,
    required List<OutfitPiece> pieces,
  }) async {
    final ids = await _saveOutfit(
      outfitId: editingOutfitId,
      entryId: (editingEntryId == null || editingEntryId.isEmpty) ? null : editingEntryId,
      name: name,
      date: date,
      pieces: [
        for (final p in pieces)
          {
            'clothing_item_id': p.item.id,
            'position_x': p.offset.dx,
            'position_y': p.offset.dy,
            'scale': p.scale,
          },
      ],
    );
    await _refetchOrThrow();
    final saved = byId(ids.entryId);
    if (saved == null) throw const BackendException('Couldn’t save your outfit. Please try again.');
    return saved;
  }

  /// Calendar → outfit detail → "Edit Details": rename the look, move the
  /// entry to another date, and edit its diary note.
  Future<void> updateEntryDetails(
    SavedOutfit entry, {
    required String name,
    required DateTime date,
    required String? note,
  }) async {
    await _saveOutfit(
      outfitId: entry.outfitId,
      entryId: entry.id.isEmpty ? null : entry.id,
      name: name,
      date: date,
      note: note,
      updateNote: true,
    );
    await _refetchOrThrow();
  }

  /// Log Outfit → "Save Entry": wear a saved look on [date], with a note.
  Future<void> logEntry({
    required String outfitId,
    required DateTime date,
    String? note,
  }) async {
    final uid = SupabaseConfig.isInitialized ? supabase.auth.currentUser?.id : null;
    if (uid == null) throw const BackendException('You’ve been logged out. Please log in again.');
    try {
      await supabase.from('calendar_entries').insert({
        'user_id': uid,
        'outfit_id': outfitId,
        'worn_on': _isoDate(date),
        'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
      });
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
    await _refetchOrThrow();
  }

  /// Calendar → outfit detail → "Delete": removes this date's entry, and the
  /// look itself too once it isn't on any other date (so it also leaves the
  /// Builder's View Outfits, as the confirmation dialog says).
  Future<void> removeEntry(SavedOutfit entry) async {
    final lastOne = _entries.where((e) => e.outfitId == entry.outfitId).length <= 1;
    try {
      if (lastOne || entry.id.isEmpty) {
        await supabase.from('outfits').delete().eq('id', entry.outfitId);
      } else {
        await supabase.from('calendar_entries').delete().eq('id', entry.id);
      }
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
    await _refetchOrThrow();
  }

  /// Outfit Builder → View Outfits → "x": removes the look and every date
  /// it was logged on.
  Future<void> removeOutfit(String outfitId) async {
    try {
      await supabase.from('outfits').delete().eq('id', outfitId);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
    await _refetchOrThrow();
  }

  Future<({String outfitId, String entryId})> _saveOutfit({
    required String? outfitId,
    required String? entryId,
    required String name,
    required DateTime date,
    List<Map<String, dynamic>>? pieces,
    String? note,
    bool updateNote = false,
  }) async {
    if (!SupabaseConfig.isInitialized || supabase.auth.currentUser == null) {
      throw const BackendException('You’ve been logged out. Please log in again.');
    }
    try {
      final dynamic result = await supabase.rpc('save_outfit', params: {
        'p_outfit_id': outfitId,
        'p_name': name.trim().isEmpty ? 'My Outfit' : name.trim(),
        'p_pieces': pieces,
        'p_entry_id': entryId,
        'p_worn_on': _isoDate(date),
        'p_note': note,
        'p_update_note': updateNote,
      });
      final Map<String, dynamic> row =
          (result is List ? result.first : result) as Map<String, dynamic>;
      return (outfitId: row['outfit_id'] as String, entryId: row['entry_id'] as String);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  Future<void> _refetchOrThrow() async {
    try {
      await _fetch();
    } catch (e) {
      throw BackendException(friendlyError(e));
    } finally {
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------

  SavedOutfit _toSaved(_EntryRow e) {
    final outfit = _outfits[e.outfitId];
    return SavedOutfit(
      id: e.id,
      outfitId: e.outfitId,
      name: outfit?.name ?? 'Outfit',
      date: e.wornOn,
      pieces: outfit == null ? const [] : _resolvePieces(outfit),
      note: e.note,
    );
  }

  /// Turns stored piece rows into board pieces using the current closet, so
  /// an item renamed or re-photographed in Closet shows up updated here.
  List<OutfitPiece> _resolvePieces(_OutfitRow outfit) {
    final closet = ClosetStore.instance;
    final pieces = <OutfitPiece>[];
    for (var i = 0; i < outfit.pieces.length; i++) {
      final p = outfit.pieces[i];
      final item = closet.byId(p.clothingItemId);
      if (item == null) continue;
      pieces.add(
        OutfitPiece(id: 'db_${outfit.id}_$i', item: item, offset: Offset(p.x, p.y), scale: p.scale),
      );
    }
    return pieces;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _OutfitRow {
  const _OutfitRow({required this.id, required this.name, required this.createdAt, required this.pieces});

  factory _OutfitRow.fromJson(Map<String, dynamic> j) {
    final raw = [
      for (final p in (j['outfit_items'] as List<dynamic>? ?? const []))
        Map<String, dynamic>.from(p as Map),
    ]..sort((a, b) => ((a['sort_order'] as num?) ?? 0).compareTo((b['sort_order'] as num?) ?? 0));
    return _OutfitRow(
      id: j['id'] as String,
      name: j['name'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
      pieces: [
        for (final p in raw)
          _PieceRow(
            clothingItemId: p['clothing_item_id'] as String,
            x: (p['position_x'] as num?)?.toDouble() ?? 0,
            y: (p['position_y'] as num?)?.toDouble() ?? 0,
            scale: ((p['scale'] as num?)?.toDouble() ?? 1)
                .clamp(OutfitPiece.minScale, OutfitPiece.maxScale)
                .toDouble(),
          ),
      ],
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final List<_PieceRow> pieces;
}

class _PieceRow {
  const _PieceRow({
    required this.clothingItemId,
    required this.x,
    required this.y,
    this.scale = 1,
  });
  final double scale;
  final String clothingItemId;
  final double x;
  final double y;
}

class _EntryRow {
  const _EntryRow({
    required this.id,
    required this.outfitId,
    required this.wornOn,
    required this.note,
    required this.createdAt,
  });

  factory _EntryRow.fromJson(Map<String, dynamic> j) {
    // "YYYY-MM-DD" -> a local calendar date (no time zone shift).
    final parts = (j['worn_on'] as String).split('-').map(int.parse).toList();
    return _EntryRow(
      id: j['id'] as String,
      outfitId: j['outfit_id'] as String,
      wornOn: DateTime(parts[0], parts[1], parts[2]),
      note: j['note'] as String?,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  final String id;
  final String outfitId;
  final DateTime wornOn;
  final String? note;
  final DateTime createdAt;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';