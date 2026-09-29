import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/clothing_item.dart';
import '../services/backend_errors.dart';
import '../services/image_bytes.dart';
import '../services/supabase_config.dart';
import 'outfit_store.dart';

/// Single source of truth for the signed-in user's Digital Closet, backed by
/// the Supabase `clothing_items` table and the private `clothing-images`
/// Storage bucket. Same singleton + [ChangeNotifier] pattern as the other
/// stores, so Closet, Home, Outfit Builder and Calendar all read one list.
///
/// Times worn / last worn / days unworn are derived from the Calendar
/// (OutfitStore) rather than stored, so they always match what was logged.
class ClosetStore extends ChangeNotifier {
  ClosetStore._() {
    // New or edited calendar entries change the wear stats.
    OutfitStore.instance.addListener(_invalidate);
  }

  static final ClosetStore instance = ClosetStore._();

  static const bucket = 'clothing-images';

  /// Signed image URLs are valid this long and refreshed before they expire.
  static const _signedUrlSeconds = 12 * 60 * 60;
  static const _refreshEvery = Duration(hours: 11);

  final List<_ItemRow> _rows = [];
  final Map<String, String> _signedUrls = {};
  List<ClothingItem>? _cache;
  Timer? _urlRefresh;

  bool _loading = false;
  bool _loaded = false;
  String? _error;

  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;

  /// Friendly message from the last failed [load], if any.
  String? get error => _error;

  /// Every item, most recently added first, with wear stats filled in.
  List<ClothingItem> get items => _cache ??= List.unmodifiable(_rows.map(_toItem));

  ClothingItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Loading

  Future<void> load() async {
    if (!SupabaseConfig.isInitialized) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await supabase
          .from('clothing_items')
          .select('id, name, category, occasion, color, image_path, is_favorite, created_at')
          .order('created_at', ascending: false);
      _rows
        ..clear()
        ..addAll(data.map(_ItemRow.fromJson));
      await _signUrls(_rows.map((r) => r.imagePath).whereType<String>().toList());
      _loaded = true;
      _urlRefresh?.cancel();
      _urlRefresh = Timer.periodic(_refreshEvery, (_) => _refreshUrls());
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _loading = false;
      _invalidate();
    }
  }

  /// Forget everything (on log out) so the next user never sees it.
  void clear() {
    _urlRefresh?.cancel();
    _urlRefresh = null;
    _rows.clear();
    _signedUrls.clear();
    _loaded = false;
    _error = null;
    _invalidate();
  }

  // ---------------------------------------------------------------------------
  // Changes. Each throws [BackendException] with a friendly message.

  /// Add Clothes → "Save to Closet". [photoPng] is the transparent cutout
  /// from the background remover; it is uploaded exactly as-is (no preview
  /// backdrop is ever painted into it).
  Future<ClothingItem> add({
    required String name,
    required String category,
    required String occasion,
    required String color,
    Uint8List? photoPng,
  }) async {
    final uid = _requireUser();
    final id = _uuidV4();
    String? path;
    try {
      if (photoPng != null) path = await _upload(uid, photoPng);
      final row = await supabase
          .from('clothing_items')
          .insert({
            'id': id,
            'user_id': uid,
            'name': name.trim(),
            'category': category,
            'occasion': occasion,
            'color': color,
            'image_path': path,
          })
          .select('id, name, category, occasion, color, image_path, is_favorite, created_at')
          .single();
      _rows.insert(0, _ItemRow.fromJson(row));
      _invalidate();
      return byId(id)!;
    } catch (e) {
      if (path != null) await _removeFiles([path]); // don't leave an orphan
      throw BackendException(friendlyError(e));
    }
  }

  /// Edit Item → "Save Changes". Pass [newPhotoPng] to replace the photo or
  /// [removePhoto] to drop it.
  Future<ClothingItem> update(
    ClothingItem edited, {
    Uint8List? newPhotoPng,
    bool removePhoto = false,
  }) async {
    final uid = _requireUser();
    final index = _rows.indexWhere((r) => r.id == edited.id);
    if (index == -1) throw const BackendException('That item no longer exists.');
    final oldPath = _rows[index].imagePath;
    String? newPath;
    try {
      if (newPhotoPng != null) newPath = await _upload(uid, newPhotoPng);
      final changes = <String, dynamic>{
        'name': edited.name.trim(),
        'category': edited.category,
        'occasion': edited.occasion,
        'color': edited.color,
        'is_favorite': edited.isFavorite,
      };
      if (newPath != null) {
        changes['image_path'] = newPath;
      } else if (removePhoto) {
        changes['image_path'] = null;
      }
      final row = await supabase
          .from('clothing_items')
          .update(changes)
          .eq('id', edited.id)
          .select('id, name, category, occasion, color, image_path, is_favorite, created_at')
          .single();
      _rows[index] = _ItemRow.fromJson(row);
      if (oldPath != null && (newPath != null || removePhoto)) {
        await _removeFiles([oldPath]);
      }
      _invalidate();
      return byId(edited.id)!;
    } catch (e) {
      if (newPath != null) await _removeFiles([newPath]);
      throw BackendException(friendlyError(e));
    }
  }

  /// The heart on a tile or the detail screen. Updates the UI right away
  /// and rolls back if the save fails.
  Future<void> toggleFavorite(String id) async {
    _requireUser();
    final index = _rows.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final before = _rows[index];
    _rows[index] = before.copyWith(isFavorite: !before.isFavorite);
    _invalidate();
    try {
      await supabase
          .from('clothing_items')
          .update({'is_favorite': !before.isFavorite})
          .eq('id', id);
    } catch (e) {
      final i = _rows.indexWhere((r) => r.id == id);
      if (i != -1) _rows[i] = before;
      _invalidate();
      throw BackendException(friendlyError(e));
    }
  }

  /// Deletes the item (the database also removes it from any outfits) and
  /// then its photo.
  Future<void> delete(String id) async {
    _requireUser();
    final index = _rows.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final path = _rows[index].imagePath;
    try {
      await supabase.from('clothing_items').delete().eq('id', id);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
    _rows.removeWhere((r) => r.id == id);
    if (path != null) await _removeFiles([path]);
    _invalidate();
    // Outfits that contained it have lost a piece.
    unawaited(OutfitStore.instance.refresh());
  }

  // ---------------------------------------------------------------------------
  // Internals

  String _requireUser() {
    final uid = SupabaseConfig.isInitialized ? supabase.auth.currentUser?.id : null;
    if (uid == null) {
      throw const BackendException('You’ve been logged out. Please log in again.');
    }
    return uid;
  }

  /// Uploads a PNG into the user's own folder and returns its path.
  Future<String> _upload(String uid, Uint8List png) async {
    if (!isPng(png)) {
      throw const BackendException('Only the background-removed PNG can be saved.');
    }
    final path = '$uid/${_uuidV4()}.png';
    await supabase.storage.from(bucket).uploadBinary(
          path,
          png,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: false),
        );
    await _signUrls([path]);
    return path;
  }

  Future<void> _removeFiles(List<String> paths) async {
    try {
      await supabase.storage.from(bucket).remove(paths);
    } catch (e) {
      debugPrint('[Love My Closet] could not remove $paths: $e');
    }
    for (final p in paths) {
      _signedUrls.remove(p);
    }
  }

  Future<void> _signUrls(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      final signed = await supabase.storage.from(bucket).createSignedUrls(paths, _signedUrlSeconds);
      for (final s in signed) {
        _signedUrls[s.path] = s.signedUrl;
      }
    } catch (e) {
      // Items still show (with their icon) if a URL can't be signed.
      debugPrint('[Love My Closet] could not sign image URLs: $e');
    }
  }

  Future<void> _refreshUrls() async {
    if (!SupabaseConfig.isInitialized || supabase.auth.currentUser == null) return;
    await _signUrls(_rows.map((r) => r.imagePath).whereType<String>().toList());
    _invalidate();
  }

  void _invalidate() {
    _cache = null;
    notifyListeners();
  }

  ClothingItem _toItem(_ItemRow row) {
    final today = _dateOnly(DateTime.now());
    final worn = OutfitStore.instance.wornDatesFor(row.id, upTo: today);
    final last = worn.isEmpty ? null : worn.reduce((a, b) => a.isAfter(b) ? a : b);
    final since = last ?? _dateOnly(row.createdAt.toLocal());
    final daysUnworn = today.difference(since).inDays;
    return ClothingItem(
      id: row.id,
      name: row.name,
      category: row.category,
      occasion: row.occasion,
      color: row.color,
      isFavorite: row.isFavorite,
      imagePath: row.imagePath,
      imageUrl: row.imagePath == null ? null : _signedUrls[row.imagePath],
      timesWorn: worn.length,
      lastWorn: last == null ? null : _formatShortDate(last),
      daysUnworn: daysUnworn < 0 ? 0 : daysUnworn,
    );
  }
}

class _ItemRow {
  const _ItemRow({
    required this.id,
    required this.name,
    required this.category,
    required this.occasion,
    required this.color,
    required this.imagePath,
    required this.isFavorite,
    required this.createdAt,
  });

  factory _ItemRow.fromJson(Map<String, dynamic> j) => _ItemRow(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        occasion: j['occasion'] as String,
        color: j['color'] as String,
        imagePath: j['image_path'] as String?,
        isFavorite: j['is_favorite'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  final String id;
  final String name;
  final String category;
  final String occasion;
  final String color;
  final String? imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  _ItemRow copyWith({bool? isFavorite}) => _ItemRow(
        id: id,
        name: name,
        category: category,
        occasion: occasion,
        color: color,
        imagePath: imagePath,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt,
      );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _formatShortDate(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

final _random = Random.secure();

/// Random (version 4) UUID, so an item's id is known before it is saved.
String _uuidV4() {
  final b = List<int>.generate(16, (_) => _random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String hex(int from, int to) =>
      b.sublist(from, to).map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}