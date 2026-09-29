import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'auth_layout.dart';

/// Forgot Password: enter your email to get a reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Asks Supabase to email a reset link. The link opens the app on the
  /// Set New Password screen.
  Future<void> _submit() async {
    if (_sending || !_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    String message;
    try {
      await AuthService.sendPasswordReset(_emailController.text);
      // Same wording whether or not the email has an account, so this
      // screen can't be used to find out who is registered.
      message = 'If that email has an account, a reset link is on its way. Check your inbox.';
    } on BackendException catch (e) {
      message = e.message;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.labelSmall!;

    return AuthLayout(
      title: 'Forgot Password',
      subtitle: 'Enter your email and we’ll send you\na reset link right away.',
      showAvatar: true,
      footer: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: AppColors.mutedBrown,
              ),
              Text('Back to Login', style: caption),
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
              label: 'Your email address',
              showLabel: false,
              prefixIcon: Icons.mail_outline_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: Validators.email,
            ),
            const SizedBox(height: Spacing.md),
            PrimaryButton(
              label: _sending ? 'Sending…' : 'Send Reset Link',
              onPressed: _sending ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}