import 'package:flutter/material.dart';

import '../../data/accessibility_store.dart';
import '../../theme.dart';
import '../../widgets/dot_pattern.dart';

/// Accessibility: Text Size, Reduce Motion, and High Contrast. Every toggle
/// here writes straight to [AccessibilityStore], which `main.dart` applies
/// app-wide, so a change here is visible the moment you go back — on every
/// screen, not just this one — and switching a setting back off returns the
/// app to exactly how it looked before.
class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  final _store = AccessibilityStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

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
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              Spacing.lg,
            ),
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.hotPink,
                          size: 32,
                        ),
                      ),
                    ),
                    Text(
                      'Accessibility',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'These apply everywhere in the app right away, and switch '
                'back to normal the moment you turn them off.',
                style: textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: Spacing.lg),
              _SettingCard(
                icon: Icons.text_fields_rounded,
                title: 'Text Size',
                subtitle: 'Make text throughout the app smaller or larger.',
                child: _TextSizeSegments(
                  value: _store.textSize,
                  onChanged: _store.setTextSize,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              _SettingCard(
                icon: Icons.motion_photos_off_outlined,
                title: 'Reduce Motion',
                subtitle: 'Cuts down slide, fade, and swipe animations.',
                child: Switch(
                  value: _store.reduceMotion,
                  activeColor: AppColors.buttonPink,
                  onChanged: _store.setReduceMotion,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              _SettingCard(
                icon: Icons.contrast_rounded,
                title: 'High Contrast',
                subtitle: 'Deepens colors to make text easier to read.',
                child: Switch(
                  value: _store.highContrast,
                  activeColor: AppColors.buttonPink,
                  onChanged: _store.setHighContrast,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White, blush-bordered card matching Profile's rows — an icon, a title,
/// a short subtitle, and a control (segmented picker or switch) on top.
class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.buttonPink, size: 20),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.hotPink,
                    fontSize: 15,
                  ),
                ),
              ),
              if (child is Switch) child,
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            subtitle,
            style: textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.3),
          ),
          if (child is! Switch) ...[
            const SizedBox(height: Spacing.sm),
            child,
          ],
        ],
      ),
    );
  }
}

/// Small/Default/Large segmented picker for Text Size.
class _TextSizeSegments extends StatelessWidget {
  const _TextSizeSegments({required this.value, required this.onChanged});

  final TextSizeOption value;
  final ValueChanged<TextSizeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.blush, width: 1.5),
      ),
      child: Row(
        children: [
          for (final option in TextSizeOption.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: kMotionDuration(const Duration(milliseconds: 150)),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: option == value
                        ? LinearGradient(
                            colors: [AppColors.softPink, AppColors.buttonPink],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(
                      AppRadius.button - 4,
                    ),
                  ),
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: option == value
                          ? AppColors.white
                          : AppColors.mutedBrown,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}