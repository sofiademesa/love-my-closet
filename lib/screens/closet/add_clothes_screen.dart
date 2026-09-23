import 'package:flutter/material.dart';

import '../../models/clothing_item.dart';
import '../../theme.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'adding_item_photo_screen.dart';

/// Add Clothes: the "new item" form reached from the Closet FAB. Takes a
/// photo (via [AddingItemPhotoScreen]), a name, category, occasion tag, and
/// color, then hands a new [ClothingItem] back to Closet.
class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  final _nameController = TextEditingController();
  String? _category;
  String? _occasion;
  String? _color;
  bool _hasPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddingItemPhotoScreen()),
    );
    if (confirmed == true) {
      setState(() => _hasPhoto = true);
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and category first, please!')),
      );
      return;
    }
    Navigator.of(context).pop(
      ClothingItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _category!,
        occasion: _occasion ?? 'Everyday',
        daysUnworn: 0,
        color: _color ?? 'Pink',
      ),
    );
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
            children: [
              Row(
                children: [
                  BackCircleButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: Spacing.sm),
                  Text('Add Clothes', style: textTheme.headlineSmall!.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: Spacing.md),
              PhotoPicker(
                imagePath: _hasPhoto ? 'placeholder' : null,
                onPick: _pickPhoto,
                onRemove: () => setState(() => _hasPhoto = false),
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                label: 'Clothing Name',
                controller: _nameController,
                hintText: 'e.g. Pink Polkadot Top',
              ),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Category',
                value: _category,
                items: clothingCategories,
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: Spacing.md),
              Text('Occasion Tags', style: textTheme.bodyMedium),
              const SizedBox(height: Spacing.sm),
              FilterChips(
                options: occasionTags,
                selected: _occasion,
                onSelected: (v) => setState(() => _occasion = v),
              ),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Color',
                value: _color,
                items: clothingColors,
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(label: 'Save to Closet', onPressed: _save),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}