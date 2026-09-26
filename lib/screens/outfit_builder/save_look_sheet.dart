import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Result of the "Save this look" sheet: the name and date the user chose.
class SaveLookResult {
  const SaveLookResult({required this.name, required this.date});
  final String name;
  final DateTime date;
}

/// Shows the "Save this look" sheet from the mockup and resolves with the
/// chosen name/date, or `null` if the user cancels.
Future<SaveLookResult?> showSaveLookSheet(
  BuildContext context, {
  String initialName = '',
  DateTime? initialDate,
}) {
  return showModalBottomSheet<SaveLookResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SaveLookSheet(initialName: initialName, initialDate: initialDate),
  );
}

class SaveLookSheet extends StatefulWidget {
  const SaveLookSheet({super.key, this.initialName = '', this.initialDate});

  final String initialName;
  final DateTime? initialDate;

  @override
  State<SaveLookSheet> createState() => _SaveLookSheetState();
}

class _SaveLookSheetState extends State<SaveLookSheet> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _dateController = TextEditingController(text: _dateLabel);
  late DateTime _date = widget.initialDate ?? DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String get _dateLabel =>
      '${_date.month.toString().padLeft(2, '0')}/'
      '${_date.day.toString().padLeft(2, '0')}/'
      '${_date.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 2),
      lastDate: DateTime(_date.year + 2),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = _dateLabel;
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      SaveLookResult(name: name.isEmpty ? 'My Outfit' : name, date: _date),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              "Give it a name and date so it's easy to find later.",
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
              label: 'Date',
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              suffixIcon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
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