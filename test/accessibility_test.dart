import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/data/accessibility_store.dart';
import 'package:final_project/models/clothing_item.dart';

void main() {
  final store = AccessibilityStore.instance;

  setUp(() {
    store.setTextSize(TextSizeOption.standard);
    store.setReduceMotion(false);
  });

  test('large text size scales by 1.15', () {
    store.setTextSize(TextSizeOption.large);
    expect(store.textSize.scale, 1.15);
  });

  test('reduce motion collapses animation duration to zero', () {
    const normal = Duration(milliseconds: 300);
    expect(kMotionDuration(normal), normal);
    store.setReduceMotion(true);
    expect(kMotionDuration(normal), Duration.zero);
  });

  test('favoriting an item via copyWith', () {
    const item = ClothingItem(
        id: '1', name: 'Tee', category: 'Tops', occasion: 'Everyday');
    expect(item.isFavorite, false);
    expect(item.copyWith(isFavorite: true).isFavorite, true);
  });

  test('unknown color falls back to White', () {
    expect(normalizeClothingColor('Neon'), 'White');
    expect(normalizeClothingColor(null), 'White');
  });
}