// Tests for the closet model and ClosetStore.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/data/closet_store.dart';
import 'package:final_project/models/clothing_item.dart';
import 'package:final_project/services/backend_errors.dart';

void main() {
  final closet = ClosetStore.instance;

  setUp(() => closet.clear());

  group('ClothingItem', () {
    const item = ClothingItem(
      id: '1',
      name: 'Denim Jacket',
      category: 'Outerwear',
      occasion: 'Everyday',
    );

    test('has sensible defaults', () {
      expect(item.isFavorite, false);
      expect(item.color, 'White');
      expect(item.timesWorn, 0);
      expect(item.daysUnworn, 0);
      expect(item.lastWorn, isNull);
      expect(item.imagePath, isNull);
      expect(item.icon, Icons.checkroom_rounded);
    });

    test('favoriting and unfavoriting with copyWith', () {
      final fav = item.copyWith(isFavorite: true);
      expect(fav.isFavorite, true);
      expect(fav.copyWith(isFavorite: false).isFavorite, false);
    });

    test('copyWith keeps the id and untouched fields', () {
      final edited = item.copyWith(name: 'Black Jacket', color: 'Black');
      expect(edited.id, '1');
      expect(edited.name, 'Black Jacket');
      expect(edited.color, 'Black');
      expect(edited.category, 'Outerwear');
      expect(edited.occasion, 'Everyday');
    });

    test('copyWith does not change the original', () {
      item.copyWith(name: 'Other', isFavorite: true);
      expect(item.name, 'Denim Jacket');
      expect(item.isFavorite, false);
    });
  });

  group('categories and colors', () {
    test('category list matches the dropdown', () {
      expect(clothingCategories, [
        'Tops',
        'Bottoms',
        'Dresses',
        'Outerwear',
        'Shoes',
        'Accessories',
      ]);
    });

    test('known colors are kept', () {
      for (final c in clothingColors) {
        expect(normalizeClothingColor(c), c);
      }
    });

    test('unknown or missing colors become White', () {
      expect(normalizeClothingColor('Transparent'), 'White');
      expect(normalizeClothingColor('Neon'), 'White');
      expect(normalizeClothingColor(''), 'White');
      expect(normalizeClothingColor(null), 'White');
    });
  });

  group('ClosetStore (empty closet / logged out)', () {
    test('a fresh closet is empty', () {
      expect(closet.items, isEmpty);
      expect(closet.byId('nope'), isNull);
      expect(closet.isLoading, false);
      expect(closet.hasLoaded, false);
      expect(closet.error, isNull);
    });

    test('the items list cannot be edited from outside', () {
      expect(
        () => closet.items.add(
          const ClothingItem(id: 'x', name: 'x', category: 'Tops', occasion: 'Everyday'),
        ),
        throwsUnsupportedError,
      );
    });

    test('load() does nothing when the backend is not initialized', () async {
      await closet.load();
      expect(closet.hasLoaded, false);
      expect(closet.isLoading, false);
      expect(closet.error, isNull);
      expect(closet.items, isEmpty);
    });

    test('adding an item while logged out fails and leaves the closet empty', () async {
      await expectLater(
        closet.add(
          name: 'Tee',
          category: 'Tops',
          occasion: 'Everyday',
          color: 'White',
        ),
        throwsA(
          isA<BackendException>().having((e) => e.message, 'message', contains('logged out')),
        ),
      );
      expect(closet.items, isEmpty);
    });

    test('favoriting while logged out fails', () async {
      await expectLater(closet.toggleFavorite('1'), throwsA(isA<BackendException>()));
    });

    test('deleting while logged out fails', () async {
      await expectLater(closet.delete('1'), throwsA(isA<BackendException>()));
    });

    test('clear() notifies listeners and resets the loaded flag', () {
      var calls = 0;
      void listener() => calls++;
      closet.addListener(listener);
      closet.clear();
      closet.removeListener(listener);

      expect(calls, greaterThanOrEqualTo(1));
      expect(closet.hasLoaded, false);
      expect(closet.items, isEmpty);
    });
  });
}