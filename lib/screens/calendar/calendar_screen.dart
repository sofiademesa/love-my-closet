import 'package:flutter/material.dart';

import '../../data/outfit_store.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/clothing_thumb.dart';
import '../../widgets/dot_pattern.dart';
import '../closet/closet_screen.dart';
import '../home/home_screen.dart';
import '../outfit_builder/outfit_builder_screen.dart';
import '../profile/profile_screen.dart';
import 'outfit_detail_sheet.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _kWeekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

String _formatLongDate(DateTime date) =>
    '${_kMonthNames[date.month - 1]} ${date.day}, ${date.year}';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// My Calendar: a month grid marking every date with a logged outfit, plus
/// a detail card for whichever date is selected. Reads outfits straight
/// from [OutfitStore] — the same list the Outfit Builder saves to — so an
/// outfit created (or edited, or deleted) in the Builder shows up here
/// automatically, with no separate calendar data of its own.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.userName = 'Sofia',
    this.closetItems = sampleClosetItems,
  });

  final String userName;
  final List<ClothingItem> closetItems;

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
  }

  @override
  void dispose() {
    OutfitStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  Future<void> _openLogOutfit() async {
    // The "+" action always goes straight to the Outfit Builder to build
    // (or pick and re-save) a look.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OutfitBuilderScreen(
          userName: widget.userName,
          closetItems: widget.closetItems,
        ),
      ),
    );
    // OutfitStore's own listener already triggers a rebuild once an entry
    // is saved, but this covers the (rare) case the screen closes without a
    // notifyListeners in between.
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
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClosetScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OutfitBuilderScreen(closetItems: widget.closetItems),
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
                  const SizedBox(height: Spacing.sm),
                  _DottedDivider(),
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
                            _MonthArrow(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => _changeMonth(-1),
                            ),
                            Expanded(
                              child: Text(
                                '${_kMonthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                                textAlign: TextAlign.center,
                                style: textTheme.headlineSmall!.copyWith(fontSize: 17),
                              ),
                            ),
                            _MonthArrow(
                              icon: Icons.chevron_right_rounded,
                              onTap: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.sm),
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
                  const SizedBox(height: Spacing.lg),
                  Text(
                    _formatLongDate(_selectedDate),
                    style: textTheme.headlineSmall!.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: Spacing.sm),
                  if (selectedOutfits.isEmpty)
                    const _NoOutfitCard()
                  else
                    for (final outfit in selectedOutfits) ...[
                      _LoggedOutfitCard(
                        outfit: outfit,
                        onTap: () => _openOutfitDetail(outfit),
                      ),
                      const SizedBox(height: Spacing.sm),
                    ],
                ],
              ),
              // Floating "log outfit" action, sitting above the nav bar.
              Positioned(
                right: Spacing.md,
                bottom: 92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.glow(AppColors.buttonPink),
                  ),
                  child: FloatingActionButton(
                    onPressed: _openLogOutfit,
                    backgroundColor: AppColors.buttonPink,
                    foregroundColor: AppColors.white,
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(currentIndex: 3, onTap: _goToTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dashWidth + gap)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: gap / 2),
                  child: Container(
                    width: dashWidth,
                    height: 1.5,
                    color: AppColors.softPink.withValues(alpha: 0.35),
                  ),
                ),
            ],
          );
        },
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
        child: Container(
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
              Text(
                '$day',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: numberColor,
                ),
              ),
              if (hasOutfit)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                ),
            ],
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
                if (outfit.note != null && outfit.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Note: ${outfit.note}',
                    style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                  ),
                ],
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    for (final piece in outfit.pieces.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: Column(
                          children: [
                            ClothingThumb(icon: piece.item.icon, size: 64, iconSize: 26),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}