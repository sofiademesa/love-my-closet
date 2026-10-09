import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../data/outfit_store.dart';
import '../../models/outfit.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../outfit_builder/outfit_builder_screen.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatLongDate(DateTime date) =>
    '${_kMonthNames[date.month - 1]} ${date.day}, ${date.year}';

/// Log Outfit: record that a previously-saved outfit was worn on [date],
/// with a diary note. The "Outfit Worn" dropdown lists the user's saved
/// looks from [OutfitStore]; saving adds a `calendar_entries` row in
/// Supabase, which is what makes it show up on the Calendar for [date].
class LogOutfitScreen extends StatefulWidget {
  const LogOutfitScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<LogOutfitScreen> createState() => _LogOutfitScreenState();
}

class _LogOutfitScreenState extends State<LogOutfitScreen> {
  final _noteController = TextEditingController();
  String? _selectedOutfitName;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  List<SavedOutfit> get _savedOutfits {
    // One dropdown entry per outfit *name* (most recently saved wins),
    // since the mockup dropdown lists looks by name, not by id.
    final byName = <String, SavedOutfit>{};
    for (final outfit in OutfitStore.instance.builderOutfits) {
      byName.putIfAbsent(outfit.name, () => outfit);
    }
    return byName.values.toList();
  }

  void _buildNewLook() {
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => OutfitBuilderScreen(initialDate: widget.date)),
    );
  }

  Future<void> _save() async {
    final name = _selectedOutfitName;
    if (name == null || _saving) return;
    final source = _savedOutfits.firstWhere((o) => o.name == name);
    setState(() => _saving = true);
    try {
      await OutfitStore.instance.logEntry(
        outfitId: source.outfitId,
        date: widget.date,
        note: _noteController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
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
                        'No saved outfits yet. Build one now and it will be saved '
                        'on this date.',
                        style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: Spacing.lg),
                      PrimaryButton(label: 'Build a New Look', onPressed: _buildNewLook),
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
                        label: _saving ? 'Saving…' : 'Save Entry',
                        onPressed: (_selectedOutfitName == null || _saving) ? null : _save,
                      ),
                      const SizedBox(height: Spacing.md),
                      Center(
                        child: Text(
                          'or',
                          style: textTheme.labelSmall!.copyWith(
                            color: AppColors.mutedBrown.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      SecondaryButton(
                        label: 'Build a New Look',
                        onPressed: _saving ? null : _buildNewLook,
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