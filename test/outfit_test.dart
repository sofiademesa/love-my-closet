// Tests for outfit pieces, saved outfits and OutfitStore.
// No Supabase: with the backend not initialized, saving/logging throws a
// friendly BackendException before any network call.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/data/outfit_store.dart';
import 'package:final_project/models/clothing_item.dart';
import 'package:final_project/models/outfit.dart';
import 'package:final_project/services/backend_errors.dart';

const _tee = ClothingItem(id: 't1', name: 'Tee', category: 'Tops', occasion: 'Everyday');
const _jeans = ClothingItem(id: 'b1', name: 'Jeans', category: 'Bottoms', occasion: 'Everyday');

void main() {
  final store = OutfitStore.instance;

  setUp(() => store.clear());

  group('OutfitPiece', () {
    test('scale limits are 0.4 to 3.0', () {
      expect(OutfitPiece.minScale, 0.4);
      expect(OutfitPiece.maxScale, 3.0);
    });

    test('a new piece starts at default size (scale 1)', () {
      final piece = OutfitPiece(id: 'p1', item: _tee, offset: const Offset(10, 20));
      expect(piece.scale, 1);
      expect(piece.offset, const Offset(10, 20));
    });

    test('changing the scale of a piece', () {
      final piece = OutfitPiece(id: 'p1', item: _tee, offset: Offset.zero);
      piece.scale = 2.5;
      expect(piece.scale, 2.5);
    });

    test('clamping keeps a scale inside the allowed range', () {
      double clamp(double s) => s.clamp(OutfitPiece.minScale, OutfitPiece.maxScale).toDouble();
      expect(clamp(0.1), OutfitPiece.minScale);
      expect(clamp(1.5), 1.5);
      expect(clamp(10), OutfitPiece.maxScale);
    });

    test('moving a piece changes its offset', () {
      final piece = OutfitPiece(id: 'p1', item: _tee, offset: Offset.zero);
      piece.offset = const Offset(50, 80);
      expect(piece.offset, const Offset(50, 80));
    });

    test('copy() is independent from the original', () {
      final original = OutfitPiece(id: 'p1', item: _tee, offset: const Offset(1, 2), scale: 1.2);
      final copy = original.copy();

      expect(copy.id, original.id);
      expect(copy.item, same(original.item));
      expect(copy.offset, original.offset);
      expect(copy.scale, original.scale);

      copy.scale = 2;
      copy.offset = const Offset(9, 9);
      expect(original.scale, 1.2);
      expect(original.offset, const Offset(1, 2));
    });
  });

  group('SavedOutfit', () {
    final pieces = [
      OutfitPiece(id: 'p1', item: _tee, offset: Offset.zero),
      OutfitPiece(id: 'p2', item: _jeans, offset: const Offset(0, 100)),
    ];
    final outfit = SavedOutfit(
      id: 'e1',
      outfitId: 'o1',
      name: 'Brunch look',
      date: DateTime(2026, 10, 1),
      pieces: pieces,
    );

    test('holds its pieces and has no note by default', () {
      expect(outfit.pieces.length, 2);
      expect(outfit.note, isNull);
    });

    test('renaming with copyWith keeps ids and pieces', () {
      final renamed = outfit.copyWith(name: 'Dinner look');
      expect(renamed.name, 'Dinner look');
      expect(renamed.id, 'e1');
      expect(renamed.outfitId, 'o1');
      expect(renamed.pieces, same(outfit.pieces));
    });

    test('removing a piece via copyWith leaves the original untouched', () {
      final smaller = outfit.copyWith(pieces: [pieces.first]);
      expect(smaller.pieces.length, 1);
      expect(outfit.pieces.length, 2);
    });

    test('editing the date and note with copyWith', () {
      final edited = outfit.copyWith(date: DateTime(2026, 10, 5), note: 'Felt great');
      expect(edited.date, DateTime(2026, 10, 5));
      expect(edited.note, 'Felt great');
    });
  });

  group('OutfitStore (empty / logged out)', () {
    test('a fresh store has no outfits', () {
      expect(store.all, isEmpty);
      expect(store.builderOutfits, isEmpty);
      expect(store.outfitCount, 0);
      expect(store.datesWithOutfits, isEmpty);
      expect(store.onDate(DateTime(2026, 10, 1)), isEmpty);
      expect(store.byId('nope'), isNull);
      expect(store.hasLoaded, false);
      expect(store.error, isNull);
    });

    test('no worn dates for an item that was never in an outfit', () {
      expect(store.wornDatesFor('t1', upTo: DateTime(2026, 12, 31)), isEmpty);
    });

    test('isSameDay compares year, month and day only', () {
      expect(
        OutfitStore.isSameDay(DateTime(2026, 10, 1, 8), DateTime(2026, 10, 1, 23)),
        true,
      );
      expect(OutfitStore.isSameDay(DateTime(2026, 10, 1), DateTime(2026, 10, 2)), false);
      expect(OutfitStore.isSameDay(DateTime(2026, 10, 1), DateTime(2025, 10, 1)), false);
    });

    test('load() does nothing when the backend is not initialized', () async {
      await store.load();
      expect(store.hasLoaded, false);
      expect(store.isLoading, false);
      expect(store.error, isNull);
    });

    test('saving an outfit while logged out fails with a friendly message', () async {
      await expectLater(
        store.saveFromBuilder(
          name: 'Test look',
          date: DateTime(2026, 10, 1),
          pieces: [OutfitPiece(id: 'p1', item: _tee, offset: Offset.zero)],
        ),
        throwsA(
          isA<BackendException>().having((e) => e.message, 'message', contains('logged out')),
        ),
      );
      expect(store.outfitCount, 0);
    });

    test('logging an outfit while logged out fails', () async {
      await expectLater(
        store.logEntry(outfitId: 'o1', date: DateTime(2026, 10, 1)),
        throwsA(isA<BackendException>()),
      );
    });

    test('editing outfit details while logged out fails', () async {
      final entry = SavedOutfit(
        id: 'e1',
        outfitId: 'o1',
        name: 'Look',
        date: DateTime(2026, 10, 1),
        pieces: const [],
      );
      await expectLater(
        store.updateEntryDetails(entry, name: 'New name', date: DateTime(2026, 10, 2), note: null),
        throwsA(isA<BackendException>()),
      );
    });

    test('clear() notifies listeners', () {
      var calls = 0;
      void listener() => calls++;
      store.addListener(listener);
      store.clear();
      store.removeListener(listener);
      expect(calls, 1);
    });
  });
}