import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Result of the "Save this look" sheet: the name and date the user chose,
/// plus the diary note when the sheet was opened with [showSaveLookSheet]'s
/// `showNote`.
///
/// [date] is null when the sheet allowed no date (`allowNoDate`) and the
/// user left it empty: the look is saved as an idea, not on the Calendar.
class SaveLookResult {
  const SaveLookResult({required this.name, required this.date, this.note});
  final String name;
  final DateTime? date;
  final String? note;
}

/// Shows the "Save this look" sheet from the mockup and resolves with the
/// chosen name/date, or `null` if the user cancels.
Future<SaveLookResult?> showSaveLookSheet(
  BuildContext context, {
  String initialName = '',
  DateTime? initialDate,
  bool showNote = false,
  String? initialNote,
  bool allowNoDate = false,
  bool onCalendar = false,
}) {
  return showModalBottomSheet<SaveLookResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SaveLookSheet(
      initialName: initialName,
      initialDate: initialDate,
      showNote: showNote,
      initialNote: initialNote,
      allowNoDate: allowNoDate,
      onCalendar: onCalendar,
    ),
  );
}

class SaveLookSheet extends StatefulWidget {
  const SaveLookSheet({
    super.key,
    this.initialName = '',
    this.initialDate,
    this.showNote = false,
    this.initialNote,
    this.allowNoDate = false,
    this.onCalendar = false,
  });

  final String initialName;
  final DateTime? initialDate;

  /// Calendar's "Edit Details" also edits the day's diary note.
  final bool showNote;
  final String? initialNote;

  /// The date can be left empty or cleared: a new look is saved as an
  /// idea, and an existing date comes off the Calendar.
  final bool allowNoDate;

  /// The look is already on the Calendar on [initialDate], so clearing the
  /// date takes it off (the sheet explains this).
  final bool onCalendar;

  @override
  State<SaveLookSheet> createState() => _SaveLookSheetState();
}

class _SaveLookSheetState extends State<SaveLookSheet> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _dateController = TextEditingController(text: _dateLabel);
  late final _noteController = TextEditingController(text: widget.initialNote ?? '');
  late DateTime? _date =
      widget.initialDate ?? (widget.allowNoDate ? null : DateTime.now());

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final d = _date;
    if (d == null) return '';
    return '${d.month.toString().padLeft(2, '0')}/'
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _pickDate() async {
    final start = _date ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: DateTime(start.year - 2),
      lastDate: DateTime(start.year + 2),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = _dateLabel;
    });
  }

  void _clearDate() {
    setState(() {
      _date = null;
      _dateController.text = '';
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      SaveLookResult(
        name: name.isEmpty ? 'My Outfit' : name,
        date: _date,
        note: widget.showNote && _date != null ? _noteController.text.trim() : null,
      ),
    );
  }

  /// True once a date the look already had has been cleared.
  bool get _removingDate => widget.onCalendar && _date == null;

  String get _removeDateHint {
    if (widget.showNote) {
      return 'This look comes off the Calendar, along with its note. '
          'It stays in your Outfit Builder.';
    }
    return 'This look comes off the Calendar but stays in your Outfit Builder.';
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      duration: const Duration(milliseconds: 300),
      offset: const Offset(0, 0.03),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.lg,
          Spacing.md,
          Spacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text('Save this look', style: textTheme.headlineSmall),
            const SizedBox(height: Spacing.xs),
            Text(
              widget.allowNoDate
                  ? 'Give it a name. Add a date only if you plan to wear it.'
                  : "Give it a name and date so it's easy to find later.",
              style: textTheme.bodyMedium!.copyWith(fontSize: 13),
            ),
            const SizedBox(height: Spacing.lg),
            AppTextField(
              label: 'Outfit Name',
              controller: _nameController,
              hintText: 'e.g. Library Run',
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: Spacing.md),
            AppTextField(
              label: widget.allowNoDate ? 'Date (optional)' : 'Date',
              controller: _dateController,
              hintText: widget.allowNoDate ? 'No date, just saving the idea' : null,
              readOnly: true,
              onTap: _pickDate,
              // Once a date is picked, the icon turns into an "x" to take it
              // back off (only where an undated save is allowed).
              suffixIcon: widget.allowNoDate && _date != null
                  ? Icons.close_rounded
                  : Icons.calendar_month_rounded,
              onSuffixTap: widget.allowNoDate && _date != null ? _clearDate : null,
              suffixTooltip: 'Remove date',
            ),
            if (_removingDate) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                _removeDateHint,
                style: textTheme.labelSmall!.copyWith(
                  color: AppColors.mutedBrown.withValues(alpha: 0.8),
                ),
              ),
            ],
            // A diary note belongs to a date, so it hides once the date is
            // cleared.
            if (widget.showNote && _date != null) ...[
              const SizedBox(height: Spacing.md),
              AppTextField(
                label: 'Note',
                controller: _noteController,
                hintText: "How did today's look feel?",
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                   child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: BorderSide(color: AppColors.blush, width: 1.5),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.bold,
                        color: AppColors.mutedBrown,
                      ),
                    ),
                   ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: PrimaryButton(label: 'Save Outfit', onPressed: _save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}