import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../data/closet_store.dart';
import '../../data/filter_icons.dart';
import '../../models/clothing_item.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/clothing_color_dot.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'adding_item_photo_screen.dart';

/// Add Clothes: the "new item" form reached from the Closet FAB. Takes a
/// photo (via [AddingItemPhotoScreen], which returns a background-removed
/// PNG), a name, category, occasion tag, and
/// color, saves it to Supabase (details in the database, the transparent PNG
/// in Storage), then hands the saved [ClothingItem] back.
class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  final _nameController = TextEditingController();
  String? _category;
  String? _occasion;
  String? _color = 'Transparent';
  /// Transparent PNG cutout from the photo flow. Uploaded as-is on Save; the
  /// preview backdrop color is only stored as the item's Color.
  Uint8List? _photoBytes;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await Navigator.of(context).push<ProcessedPhoto>(
      AppPageRoute(
        builder: (_) => AddingItemPhotoScreen(initialBackground: _color ?? 'Transparent'),
      ),
    );
    if (photo != null) {
      setState(() {
        _photoBytes = photo.bytes;
        // The Color options double as the photo's preview backdrop.
        _color = photo.backgroundColorName;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nameController.text.trim().isEmpty || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and category first, please!')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ClosetStore.instance.add(
        name: _nameController.text.trim(),
        category: _category!,
        occasion: _occasion ?? 'Everyday',
        color: _color ?? 'Transparent',
        photoPng: _photoBytes,
      );
      if (!mounted) return;
      Navigator.of(context).pop<ClothingItem>(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
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
                imageBytes: _photoBytes,
                backgroundColorName: _color ?? 'Transparent',
                onPick: _pickPhoto,
                onRemove: () => setState(() => _photoBytes = null),
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
                icons: occasionFilterIcons,
                selected: _occasion,
                onSelected: (v) => setState(() => _occasion = v),
              ),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Color',
                value: _color,
                items: clothingColors,
                onChanged: (v) => setState(() => _color = v),
                itemLeadingBuilder: (name) => ClothingColorDot(name: name),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _saving ? 'Saving…' : 'Save to Closet',
                      onPressed: _saving ? null : _save,
                    ),
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