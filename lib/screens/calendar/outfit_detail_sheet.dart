import 'package:flutter/material.dart';

import '../../data/outfit_store.dart';
import '../../models/outfit.dart';
import '../../theme.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/secondary_button.dart';
import '../outfit_builder/save_look_sheet.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatLongDate(DateTime date) =>
    '${_kMonthNames[date.month - 1]} ${date.day}, ${date.year}';

/// What the caller should do after the outfit detail sheet closes.
enum OutfitDetailAction { deleted, none }

/// Shows an outfit's full detail — name, date, note, and every piece — as a
/// bottom sheet. Reached by tapping a logged outfit on the Calendar (or the
/// "View Outfits" tab in the Builder), so it always reads live from
/// [OutfitStore] rather than a snapshot passed in.
Future<OutfitDetailAction> showOutfitDetailSheet(
  BuildContext context, {
  required String outfitId,
}) async {
  final result = await showModalBottomSheet<OutfitDetailAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OutfitDetailSheet(outfitId: outfitId),
  );
  return result ?? OutfitDetailAction.none;
}

class OutfitDetailSheet extends StatefulWidget {
  const OutfitDetailSheet({super.key, required this.outfitId});

  final String outfitId;

  @override
  State<OutfitDetailSheet> createState() => _OutfitDetailSheetState();
}

class _OutfitDetailSheetState extends State<OutfitDetailSheet> {
  Future<void> _editDetails(SavedOutfit outfit) async {
    final result = await showSaveLookSheet(
      context,
      initialName: outfit.name,
      initialDate: outfit.date,
    );
    if (result == null || !mounted) return;
    OutfitStore.instance.update(
      outfit.copyWith(name: result.name, date: result.date),
    );
    setState(() {});
  }

  Future<void> _confirmDelete(SavedOutfit outfit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Delete this outfit?'),
        content: Text(
          '"${outfit.name}" will be removed from ${_formatLongDate(outfit.date)} and from Outfit Builder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      OutfitStore.instance.remove(outfit.id);
      Navigator.of(context).pop(OutfitDetailAction.deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final outfit = OutfitStore.instance.byId(widget.outfitId);

    // The outfit could have just been deleted from underneath this sheet
    // (e.g. re-opened after a rebuild); guard rather than crash.
    if (outfit == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.lg, Spacing.md, Spacing.lg),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outfit.name, style: textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(_formatLongDate(outfit.date), style: textTheme.labelSmall),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(OutfitDetailAction.none),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blush, width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.mutedBrown),
                  ),
                ),
              ],
            ),
            if (outfit.note != null && outfit.note!.trim().isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                'Note: ${outfit.note}',
                style: textTheme.bodyMedium!.copyWith(fontSize: 13),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: [
                for (final piece in outfit.pieces)
                  SizedBox(
                    width: 84,
                    child: Column(
                      children: [
                        ClothingThumb(icon: piece.item.icon, size: 76, iconSize: 30),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          piece.item.name,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall!.copyWith(fontSize: 11, height: 1.25),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Edit Details',
                    onPressed: () => _editDetails(outfit),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmDelete(outfit),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: const BorderSide(color: AppColors.errorRed, width: 1.5),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}