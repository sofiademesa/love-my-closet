import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import 'auth_layout.dart';
import 'log_in_screen.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final firstName = _nameController.text.trim().split(' ').first;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(userName: firstName),
      ),
    );
  }

  void _goToLogIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LogInScreen()),
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
            PrimaryButton(label: 'Sign Up', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}