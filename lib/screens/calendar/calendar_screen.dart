import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../data/closet_store.dart';
import '../../data/outfit_store.dart';
import '../../models/outfit.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../closet/closet_screen.dart';
import '../home/home_screen.dart';
import '../outfit_builder/outfit_builder_screen.dart';
import '../profile/profile_screen.dart';
import 'log_outfit_screen.dart';
import 'outfit_detail_sheet.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _kWeekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

String _formatLongDate(DateTime date) =>
    '${_kMonthNames[date.month - 1]} ${date.day}, ${date.year}';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// My Calendar (the Outfit Diary): a month grid marking every date with a
/// logged outfit, plus a detail card for whichever date is selected. Reads
/// the signed-in user's calendar entries from Supabase via [OutfitStore] —
/// the same data the Outfit Builder saves to — so an outfit saved with a
/// date in the Builder shows up here on that date.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.userName = 'Sofia',
  });

  final String userName;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  final _today = _dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _visibleMonth = DateTime(_today.year, _today.month, 1);
    OutfitStore.instance.addListener(_onStoreChanged);
    ClosetStore.instance.addListener(_onStoreChanged);
    if (!OutfitStore.instance.hasLoaded && !OutfitStore.instance.isLoading) {
      OutfitStore.instance.load();
    }
  }

  @override
  void dispose() {
    OutfitStore.instance.removeListener(_onStoreChanged);
    ClosetStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  /// +1 when the last month change went forward, -1 when backward — lets
  /// the month grid slide in from the matching side.
  int _monthDirection = 1;

  void _changeMonth(int delta) {
    _monthDirection = delta >= 0 ? 1 : -1;
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  /// Slides + fades whatever month-specific content is passed in when the
  /// visible month changes, entering from the side matching the arrow tapped.
  Widget _monthSwitcher(Widget child) {
    return AnimatedSwitcher(
      duration: kMotionDuration(const Duration(milliseconds: 280)),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(_visibleMonth);
        final dx = (incoming ? 1 : -1) * _monthDirection * 0.12;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  Future<void> _openLogForSelectedDate() async {
    await Navigator.of(context).push(
      AppPageRoute(builder: (_) => LogOutfitScreen(date: _selectedDate)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openOutfitDetail(SavedOutfit outfit) async {
    await showOutfitDetailSheet(context, outfitId: outfit.id);
    if (mounted) setState(() {});
  }

  void _goToTab(int index) {
    const currentIndex = 3;
    if (index == currentIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(builder: (_) => const ClosetScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        AppPageRoute(
          builder: (_) => const OutfitBuilderScreen(),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  List<DateTime> get _gridDates {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leadingBlanks = (firstOfMonth.weekday - DateTime.monday) % 7;
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    // Built via the DateTime constructor (which normalizes out-of-range
    // day/month fields) rather than by adding day-long Durations, so this
    // can't be thrown off by a DST transition in the user's time zone.
    return [
      for (var i = 0; i < totalCells; i++)
        DateTime(_visibleMonth.year, _visibleMonth.month, 1 - leadingBlanks + i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final datesWithOutfits = OutfitStore.instance.datesWithOutfits;
    final selectedOutfits = OutfitStore.instance.onDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 110),
                children: [
                  Center(
                    child: Text(
                      'My Calendar',
                      style: textTheme.headlineSmall!.copyWith(fontSize: 26),
                    ),
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
                      children: [
                        Row(
                          children: [
                            PressableScale(
                              scale: 0.88,
                              child: _MonthArrow(
                                icon: Icons.chevron_left_rounded,
                                onTap: () => _changeMonth(-1),
                              ),
                            ),
                            Expanded(
                              child: _monthSwitcher(
                                Text(
                                  '${_kMonthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                                  key: ValueKey(_visibleMonth),
                                  textAlign: TextAlign.center,
                                  style: textTheme.headlineSmall!.copyWith(fontSize: 17),
                                ),
                              ),
                            ),
                            PressableScale(
                              scale: 0.88,
                              child: _MonthArrow(
                                icon: Icons.chevron_right_rounded,
                                onTap: () => _changeMonth(1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.sm),
                        AnimatedSize(
                          duration: kMotionDuration(const Duration(milliseconds: 250)),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: _monthSwitcher(
                            Column(
                              key: ValueKey(_visibleMonth),
                              children: [
                        Row(
                          children: [
                            for (final letter in _kWeekdayLetters)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: textTheme.labelSmall!.copyWith(
                                      color: AppColors.softPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _gridDates.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                          ),
                          itemBuilder: (context, i) {
                            final date = _gridDates[i];
                            final inMonth = date.month == _visibleMonth.month;
                            final selected = date == _selectedDate;
                            final isToday = date == _today;
                            final hasOutfit = datesWithOutfits.contains(date);
                            return _DayCell(
                              day: date.day,
                              inMonth: inMonth,
                              selected: selected,
                              isToday: isToday,
                              hasOutfit: hasOutfit,
                              onTap: inMonth ? () => _selectDate(date) : null,
                            );
                          },
                        ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  AppSectionSwitcher(
                    child: Column(
                      key: ValueKey(
                        '$_selectedDate|${selectedOutfits.map((o) => o.id).join(',')}',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _formatLongDate(_selectedDate),
                          style: textTheme.headlineSmall!.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: Spacing.sm),
                        if (selectedOutfits.isEmpty) ...[
                          const _NoOutfitCard(),
                          const SizedBox(height: Spacing.sm),
                        ] else
                          for (final outfit in selectedOutfits) ...[
                            PressableScale(
                              scale: 0.98,
                              child: _LoggedOutfitCard(
                                outfit: outfit,
                                onTap: () => _openOutfitDetail(outfit),
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                        PressableScale(
                          scale: 0.98,
                          child: _AddOutfitBar(
                            date: _selectedDate,
                            onTap: _openLogForSelectedDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.xs,
                child: BottomNavBar(currentIndex: 3, onTap: _goToTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppColors.buttonPink, size: 24),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.isToday,
    required this.hasOutfit,
    required this.onTap,
  });

  final int day;
  final bool inMonth;
  final bool selected;
  final bool isToday;
  final bool hasOutfit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final numberColor = !inMonth
        ? AppColors.mutedBrown.withValues(alpha: 0.28)
        : selected
            ? AppColors.white
            : AppColors.hotPink;
    final dotColor = selected ? AppColors.white : AppColors.buttonPink;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: kMotionDuration(const Duration(milliseconds: 220)),
          curve: Curves.easeOut,
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selected
                ? LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink])
                : null,
            border: !selected && isToday
                ? Border.all(color: AppColors.softPink, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: kMotionDuration(const Duration(milliseconds: 220)),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: numberColor,
                ),
                child: Text('$day'),
              ),
              AnimatedSwitcher(
                duration: kMotionDuration(const Duration(milliseconds: 260)),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: hasOutfit
                    ? Container(
                        key: const ValueKey('dot'),
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                      )
                    : const SizedBox.shrink(key: ValueKey('nodot')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AddOutfitBar extends StatelessWidget {
  const _AddOutfitBar({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    final label = 'Add outfit for ${_kMonthNames[date.month - 1]} ${date.day}';
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.blush, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm + 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink]),
                    ),
                    child: Icon(Icons.add_rounded, size: 18, color: AppColors.white),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoOutfitCard extends StatelessWidget {
  const _NoOutfitCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg, horizontal: Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.blush.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy_rounded, size: 26, color: AppColors.buttonPink),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'No outfit logged for this date.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium!.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LoggedOutfitCard extends StatelessWidget {
  const _LoggedOutfitCard({required this.outfit, required this.onTap});

  final SavedOutfit outfit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outfit.name, style: textTheme.headlineSmall!.copyWith(fontSize: 17)),
                const SizedBox(height: Spacing.md),
                // Top-aligned so a piece with a long (wrapping) name doesn't
                // push its photo out of line with the others.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final piece in outfit.pieces.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: Column(
                          children: [
                            ClothingThumb(
                              icon: piece.item.icon,
                              size: 64,
                              iconSize: 26,
                              imageUrl: piece.item.imageUrl,
                              backgroundColorName: piece.item.color,
                            ),
                            const SizedBox(height: Spacing.xs),
                            SizedBox(
                              width: 72,
                              child: Text(
                                piece.item.name,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall!.copyWith(fontSize: 10.5, height: 1.25),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _DiaryNote(note: outfit.note),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The day's diary note, shown as a little journal entry at the bottom of
/// the outfit card. With no note yet, a soft prompt invites adding one (the
/// whole card opens the detail sheet, where Edit Details holds the note).
class _DiaryNote extends StatelessWidget {
  const _DiaryNote({required this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = note?.trim() ?? '';
    final hasNote = text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Spacing.md - 4, Spacing.sm + 2, Spacing.md - 4, Spacing.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.field - 4),
        border: Border.all(color: AppColors.blush, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: AppColors.hotPink),
              const SizedBox(width: Spacing.xs),
              Text(
                'Diary',
                style: textTheme.labelSmall!.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hotPink,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            hasNote ? text : 'How did today’s look feel? Tap to add a note.',
            style: textTheme.bodyMedium!.copyWith(
              fontSize: 13,
              height: 1.4,
              fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
              color: hasNote ? null : AppColors.mutedBrown.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}