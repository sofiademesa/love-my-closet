import 'package:flutter/material.dart';

import '../../data/user_profile_store.dart';
import '../../theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/heart_avatar.dart';
import '../../widgets/profile_menu_row.dart';
import '../calendar/calendar_screen.dart';
import '../closet/closet_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_flow.dart';
import '../outfit_builder/outfit_builder_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';

/// Profile: account info at a glance (avatar, name, bio) plus access to app
/// settings — Edit Profile, Language, closet preferences, and Log Out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _store = UserProfileStore.instance;

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

  void _goToTab(int index) {
    const currentIndex = 4;
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
        MaterialPageRoute(builder: (_) => const OutfitBuilderScreen()),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _openHelpSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Log out?'),
        content: const Text("You'll need to log back in to see your closet."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        (route) => false,
      );
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
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.lg, Spacing.md, 110),
                children: [
                  const Center(child: HeartAvatar(width: 140)),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    "${_store.displayName}'s Closet",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall!.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _store.bio,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: Spacing.lg),
                  const _SectionLabel('General'),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: _editProfile,
                  ),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.translate_rounded,
                    label: 'Language',
                    onTap: _comingSoon,
                  ),
                  const SizedBox(height: Spacing.lg),
                  const _SectionLabel('Closet'),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.diamond_outlined,
                    label: 'Hidden Gems Threshold',
                    trailing: _ThresholdPicker(store: _store),
                  ),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    trailing: Switch(
                      value: _store.notificationsEnabled,
                      activeColor: AppColors.buttonPink,
                      onChanged: _store.setNotificationsEnabled,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  const _SectionLabel('Privacy & About'),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.info_outline_rounded,
                    label: 'About Love My Closet',
                    onTap: _comingSoon,
                  ),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: _openHelpSupport,
                  ),
                  const SizedBox(height: Spacing.sm),
                  ProfileMenuRow(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    onTap: _logOut,
                  ),
                ],
              ),
              Positioned(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
                child: BottomNavBar(currentIndex: 4, onTap: _goToTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.hotPink,
      ),
    );
  }
}

/// The small "30 days"-style pill on the Hidden Gems Threshold row. Tapping
/// it opens a menu of options; picking one writes straight to the store.
class _ThresholdPicker extends StatelessWidget {
  const _ThresholdPicker({required this.store});

  final UserProfileStore store;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: store.hiddenGemsThreshold,
      onSelected: store.setHiddenGemsThreshold,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      itemBuilder: (context) => [
        for (final option in UserProfileStore.hiddenGemsOptions)
          PopupMenuItem(value: option, child: Text(option)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              store.hiddenGemsThreshold,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedBrown,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.mutedBrown,
            ),
          ],
        ),
      ),
    );
  }
}