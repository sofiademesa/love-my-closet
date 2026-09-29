import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../data/outfit_store.dart';
import '../../models/outfit.dart';
import '../../services/backend_errors.dart';
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
/// [OutfitStore] (Supabase) rather than a snapshot passed in.
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
  bool _busy = false;

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e))));
  }

  /// Rename the look, move it to another date, and edit the diary note.
  Future<void> _editDetails(SavedOutfit outfit) async {
    if (_busy) return;
    final result = await showSaveLookSheet(
      context,
      initialName: outfit.name,
      initialDate: outfit.date,
      showNote: true,
      initialNote: outfit.note,
    );
    if (result == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await OutfitStore.instance.updateEntryDetails(
        outfit,
        name: result.name,
        date: result.date,
        note: result.note,
      );
    } catch (e) {
      _showError(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _confirmDelete(SavedOutfit outfit) async {
    final confirmed = await showAppDialog<bool>(
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
            child: Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _busy = true);
      try {
        await OutfitStore.instance.removeEntry(outfit);
        if (mounted) Navigator.of(context).pop(OutfitDetailAction.deleted);
      } catch (e) {
        if (mounted) setState(() => _busy = false);
        _showError(e);
      }
    }
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
                PressableScale(
                 scale: 0.88,
                 child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(OutfitDetailAction.none),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blush, width: 1.5),
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.mutedBrown),
                  ),
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
                    width: 104,
                    child: Column(
                      children: [
                        ClothingThumb(
                          icon: piece.item.icon,
                          size: 100,
                          iconSize: 38,
                          imageUrl: piece.item.imageUrl,
                          backgroundColorName: piece.item.color,
                        ),
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
                  child: PressableScale(
                   child: OutlinedButton(
                    onPressed: () => _confirmDelete(outfit),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: BorderSide(color: AppColors.errorRed, width: 1.5),
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorRed,
                      ),
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