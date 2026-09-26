import 'package:flutter/material.dart';

import '../../data/outfit_store.dart';
import '../../models/outfit.dart';
import '../../theme.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/primary_button.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatLongDate(DateTime date) =>
    '${_kMonthNames[date.month - 1]} ${date.day}, ${date.year}';

/// Log Outfit: record that a previously-saved outfit was worn on [date].
/// The "Outfit Worn" dropdown is populated straight from [OutfitStore] —
/// the same saved-outfit data the Builder shows — so there's no separate
/// placeholder list to keep in sync. Saving adds a new entry to that same
/// store, which is what makes it show up on the Calendar for [date].
class LogOutfitScreen extends StatefulWidget {
  const LogOutfitScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<LogOutfitScreen> createState() => _LogOutfitScreenState();
}

class _LogOutfitScreenState extends State<LogOutfitScreen> {
  final _noteController = TextEditingController();
  String? _selectedOutfitName;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<SavedOutfit> get _savedOutfits {
    // One dropdown entry per outfit *name* (most recently saved wins),
    // since the mockup dropdown lists looks by name, not by id.
    final byName = <String, SavedOutfit>{};
    for (final outfit in OutfitStore.instance.all) {
      byName.putIfAbsent(outfit.name, () => outfit);
    }
    return byName.values.toList();
  }

  void _save() {
    final name = _selectedOutfitName;
    if (name == null) return;
    final source = _savedOutfits.firstWhere((o) => o.name == name);
    OutfitStore.instance.add(
      SavedOutfit(
        id: 'log_${DateTime.now().microsecondsSinceEpoch}',
        name: source.name,
        date: widget.date,
        pieces: source.pieces.map((p) => p.copy()).toList(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final options = _savedOutfits;

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
                  BackCircleButton(onTap: () => Navigator.of(context).pop(false)),
                  const SizedBox(width: Spacing.sm),
                  Text('Log Outfit', style: textTheme.headlineSmall!.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.blush, width: 1.5),
                  boxShadow: AppShadows.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatLongDate(widget.date),
                            style: textTheme.headlineSmall!.copyWith(fontSize: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.blush.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: AppColors.mutedBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.lg),
                    if (options.isEmpty) ...[
                      Text(
                        'No saved outfits yet. Build and save one in Outfit Builder '
                        'first, then log it here.',
                        style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                      ),
                    ] else ...[
                      AppDropdown(
                        label: 'Outfit Worn',
                        value: _selectedOutfitName,
                        items: [for (final o in options) o.name],
                        onChanged: (v) => setState(() => _selectedOutfitName = v),
                      ),
                      const SizedBox(height: Spacing.md),
                      AppTextField(
                        label: 'Note',
                        controller: _noteController,
                        hintText: "How did today's look feel?",
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: Spacing.lg),
                      PrimaryButton(
                        label: 'Save Entry',
                        onPressed: _selectedOutfitName == null ? null : _save,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}