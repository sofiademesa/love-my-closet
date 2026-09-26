import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: request the password reset from the backend.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset link sent! Check your email.')),
    );
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
            PrimaryButton(label: 'Send Reset Link', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}