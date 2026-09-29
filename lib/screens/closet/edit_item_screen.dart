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

/// Edit Item: update a closet item's name, category, occasion tag, color,
/// or photo — or delete it outright. Saves to Supabase, then pops the
/// updated [ClothingItem] (or 'deleted').
class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key, required this.item});

  final ClothingItem item;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late final _nameController = TextEditingController(text: widget.item.name);
  late String _category = widget.item.category;
  late String _occasion = widget.item.occasion;
  late String _color = widget.item.color;

  /// A new transparent cutout picked via Change Photo (same flow as Add
  /// Clothes), not uploaded until Save Changes.
  Uint8List? _newPhoto;

  /// The existing photo was removed with the (x) badge.
  bool _removePhoto = false;
  bool _saving = false;

  String? get _existingPhotoUrl => _removePhoto ? null : widget.item.imageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final photo = await Navigator.of(context).push<ProcessedPhoto>(
      AppPageRoute(builder: (_) => AddingItemPhotoScreen(initialBackground: _color)),
    );
    if (photo != null && mounted) {
      setState(() {
        _newPhoto = photo.bytes;
        _color = photo.backgroundColorName;
      });
    }
  }

  void _clearPhoto() {
    setState(() {
      if (_newPhoto != null) {
        _newPhoto = null;
      } else {
        _removePhoto = true;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    setState(() => _saving = true);
    try {
      final saved = await ClosetStore.instance.update(
        widget.item.copyWith(
          name: name.isEmpty ? widget.item.name : name,
          category: _category,
          occasion: _occasion,
          color: _color,
        ),
        newPhotoPng: _newPhoto,
        removePhoto: _removePhoto && _newPhoto == null,
      );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Delete this item?'),
        content: Text('"${widget.item.name}" will be removed from your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // Tell whoever opened Edit Item (Closet, or Clothing Item detail which
      // passes it on) that it was deleted; Closet plays the exit animation
      // and removes it from Supabase.
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
            children: [
              Row(
                children: [
                  BackCircleButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: Spacing.sm),
                  Text('Edit Item', style: textTheme.headlineSmall!.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: Spacing.md),
              PhotoPicker(
                imageBytes: _newPhoto,
                imageUrl: _existingPhotoUrl,
                backgroundColorName: _color,
                icon: widget.item.icon,
                onPick: _changePhoto,
                onRemove: _clearPhoto,
              ),
              const SizedBox(height: Spacing.sm),
              Center(
                child: SizedBox(
                  width: 170,
                  child: SecondaryButton(
                    label: 'Change Photo',
                    onPressed: _changePhoto,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(label: 'Clothing Name', controller: _nameController),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Category',
                value: _category,
                items: clothingCategories,
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: Spacing.md),
              Text('Occasion Tags', style: textTheme.bodyMedium),
              const SizedBox(height: Spacing.sm),
              FilterChips(
                options: occasionTags,
                icons: occasionFilterIcons,
                selected: _occasion,
                onSelected: (v) => setState(() => _occasion = v ?? _occasion),
              ),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Color',
                value: _color,
                items: clothingColors,
                onChanged: (v) => setState(() => _color = v ?? _color),
                itemLeadingBuilder: (name) => ClothingColorDot(name: name),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _saving ? 'Saving…' : 'Save Changes',
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: SecondaryButton(label: 'Delete', onPressed: _confirmDelete),
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