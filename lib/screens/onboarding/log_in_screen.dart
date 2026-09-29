import 'package:flutter/material.dart';
import '../../animations/app_motion.dart';

import '../../services/auth_flow.dart';
import '../../services/auth_service.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'auth_layout.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';

/// Log In: email, password, remember me, forgot password link.
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      // Pull this account's closet, outfits and profile, then show Home.
      await AuthFlow.enterApp();
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      AppPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _goToSignUp() {
    Navigator.of(context).pushReplacement(
      AppPageRoute<void>(builder: (_) => const CreateAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.labelSmall!;

    return AuthLayout(
      title: 'Welcome Back',
      subtitle: 'Ready to style again?',
      showAvatar: true,
      footer: AuthFooterLink(
        prompt: 'Don’t have an account?',
        action: 'Sign Up',
        onTap: _goToSignUp,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (v) =>
                  Validators.notEmpty(v, 'Please enter your password'),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _rememberMe
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: AppColors.buttonPink,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text('Remember me', style: caption),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: _goToForgotPassword,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: Spacing.xs,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: caption.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            PrimaryButton(
              label: _submitting ? 'Logging In…' : 'Log In',
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}