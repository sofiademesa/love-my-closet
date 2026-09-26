import 'package:flutter/material.dart';

import '../../data/user_profile_store.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/heart_avatar.dart';
import '../../widgets/primary_button.dart';

/// Edit Profile: update display name, email, bio, and photo. Saving writes
/// straight to [UserProfileStore], so Profile, Home's greeting, and
/// Closet's header all pick up the change immediately.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _store = UserProfileStore.instance;

  late final _nameController = TextEditingController(text: _store.displayName);
  late final _emailController = TextEditingController(text: _store.email);
  late final _bioController = TextEditingController(text: _store.bio);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    _store.updateProfile(
      displayName: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
    );
    Navigator.of(context).pop();
  }

  void _photoComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
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
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.hotPink,
                          size: 32,
                        ),
                      ),
                    ),
                    Text(
                      'Edit Profile',
                      style: textTheme.headlineSmall!.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const HeartAvatar(width: 170),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: _photoComingSoon,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.buttonPink,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                            boxShadow: AppShadows.surface,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              AppTextField(
                label: 'Display Name',
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: Spacing.md),
              AppTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 3,
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(label: 'Save Profile', onPressed: _save),
              const SizedBox(height: Spacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}