import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../services/auth_flow.dart';
import '../../services/auth_service.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'auth_layout.dart';
import 'log_in_screen.dart';
import 'verify_email_screen.dart';

/// Create Account: full name, email, password, confirm password.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Creates the Supabase account. Their name is sent along so the profile
  /// row (created by the database) shows their real first name right away.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final outcome = await AuthService.signUp(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (outcome == SignUpOutcome.confirmEmail) {
        // Email confirmation is on. Wait on a "Check your email" screen that
        // signs in by itself the moment the link is confirmed, wherever it
        // was opened, so nobody has to log in a second time.
        Navigator.of(context).pushReplacement(
          AppPageRoute<void>(
            builder: (_) => VerifyEmailScreen(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
        return;
      }
      await AuthFlow.enterApp();
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _goToLogIn() {
    Navigator.of(context).pushReplacement(
      AppPageRoute<void>(builder: (_) => const LogInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Start your closet story',
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        action: 'Log In',
        onTap: _goToLogIn,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full Name',
              showLabel: false,
              prefixIcon: Icons.person_outline_rounded,
              controller: _nameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.notEmpty(v, 'Please enter your name'),
            ),
            const SizedBox(height: Spacing.md),
            AppTextField(
              label: 'Email Address',
              showLabel: false,
              prefixIcon: Icons.mail_outline_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: Spacing.md),
            AppTextField(
              label: 'Password',
              showLabel: false,
              prefixIcon: Icons.lock_outline_rounded,
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.length < 8)
                  ? 'Use at least 8 characters'
                  : null,
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
              validator: (v) => v != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: Spacing.lg),
            PrimaryButton(
              label: _submitting ? 'Signing Up…' : 'Sign Up',
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}