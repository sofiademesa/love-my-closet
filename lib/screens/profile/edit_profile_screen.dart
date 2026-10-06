import 'package:flutter/material.dart';

import '../../data/user_profile_store.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/heart_avatar.dart';
import '../../widgets/primary_button.dart';

/// Edit Profile: update display name, email, and bio. The avatar is the
/// app's logo, so there is no photo upload. Saving writes
/// to the Supabase `profiles` table through [UserProfileStore], so Profile,
/// Home's greeting, and Closet's header all pick up the change immediately
/// and it persists between sessions. A new email goes through Supabase
/// Auth's confirmation email.
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
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final emailChangeRequested = await _store.updateProfile(
        displayName: _nameController.text,
        email: _emailController.text,
        bio: _bioController.text,
      );
      if (emailChangeRequested) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Check your inbox to confirm your new email address.'),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
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
                        icon: Icon(
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
              const Center(child: HeartAvatar(width: 170)),
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
              PrimaryButton(
                label: _saving ? 'Saving…' : 'Save Profile',
                onPressed: _saving ? null : _save,
              ),
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