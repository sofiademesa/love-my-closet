import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../data/app_data.dart';
import '../../services/auth_service.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import 'auth_layout.dart';

/// Opened automatically when user follows the link in a password-reset
/// email (Forgot Password). Same look as Log In / Forgot Password.
class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await AuthService.updatePassword(_passwordController.text);
      await AppData.loadForCurrentUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.labelSmall!;

    return AuthLayout(
      title: 'Set New Password',
      subtitle: 'Choose a new password for your account.',
      showAvatar: true,
      footer: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.mutedBrown),
              Text('Back', style: caption),
            ],
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'New Password',
              showLabel: false,
              prefixIcon: Icons.lock_outline_rounded,
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters' : null,
            ),
            const SizedBox(height: Spacing.md),
            AppTextField(
              label: 'Confirm Password',
              showLabel: false,
              prefixIcon: Icons.lock_reset_rounded,
              controller: _confirmController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: Spacing.lg),
            PrimaryButton(
              label: _saving ? 'Saving…' : 'Update Password',
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}