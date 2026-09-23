import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../theme.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/tag_chip.dart';
import 'edit_item_screen.dart';

/// Clothing Item: a closet item's full detail, reached by tapping a tile
/// on Closet. Lets Sofia mark it a hidden gem, edit it, or delete it.
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final ClothingItem item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ClothingItem _item = widget.item;

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<ClothingItem>(
      MaterialPageRoute(builder: (_) => EditItemScreen(item: _item)),
    );
    if (updated != null) {
      setState(() => _item = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Delete this item?'),
        content: Text('"${_item.name}" will be removed from your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop('deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  100,
                ),
                children: [
                  Row(
                    children: [
                      BackCircleButton(
                        onTap: () => Navigator.of(context).pop(_item),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Clothing Item',
                        style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.blush, width: 1.5),
                      boxShadow: AppShadows.surface,
                    ),
                    child: Center(child: ClothingThumb(icon: _item.icon, size: 160)),
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _item.name,
                          style: textTheme.headlineSmall!.copyWith(fontSize: 22),
                        ),
                      ),
                      _HiddenGemToggle(
                        active: _item.isHiddenGem,
                        onTap: () => setState(
                          () => _item = _item.copyWith(isHiddenGem: !_item.isHiddenGem),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    spacing: Spacing.xs,
                    children: [
                      TagChip(label: _item.category),
                      TagChip(label: _item.occasion),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    _item.daysUnworn == 0
                        ? 'Added just now — no wears logged yet.'
                        : "You haven't worn this in ${_item.daysUnworn} days",
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Spacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(label: 'Edit Item', onPressed: _edit),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Delete',
                          onPressed: _confirmDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(
                  currentIndex: 1,
                  onTap: (_) => Navigator.of(context).pop(_item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small heart toggle marking an item as a hidden gem, next to its name.
class _HiddenGemToggle extends StatelessWidget {
  const _HiddenGemToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? AppColors.buttonPink : AppColors.blush.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: active ? AppColors.white : AppColors.mutedBrown,
        ),
      ),
    );
  }
}