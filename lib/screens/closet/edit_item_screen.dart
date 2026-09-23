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

/// Edit Item: update a closet item's name, category, occasion tag, color,
/// or photo — or delete it outright.
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
  bool _hasPhoto = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      widget.item.copyWith(
        name: name.isEmpty ? widget.item.name : name,
        category: _category,
        occasion: _occasion,
        color: _color,
      ),
    );
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
        content: Text('"${widget.item.name}" will be removed from your closet.'),
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
      // Close Edit Item, then tell Clothing Item detail it was deleted so it
      // can pop back to Closet and remove it from the grid.
      Navigator.of(context).pop();
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
                imagePath: _hasPhoto ? 'placeholder' : null,
                icon: widget.item.icon,
                onPick: () => setState(() => _hasPhoto = true),
                onRemove: () => setState(() => _hasPhoto = false),
              ),
              const SizedBox(height: Spacing.sm),
              Center(
                child: SizedBox(
                  width: 170,
                  child: SecondaryButton(
                    label: 'Change Photo',
                    onPressed: () => setState(() => _hasPhoto = true),
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
                selected: _occasion,
                onSelected: (v) => setState(() => _occasion = v ?? _occasion),
              ),
              const SizedBox(height: Spacing.md),
              AppDropdown(
                label: 'Color',
                value: _color,
                items: clothingColors,
                onChanged: (v) => setState(() => _color = v ?? _color),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(label: 'Save Changes', onPressed: _save),
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