import 'dart:async';

import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../services/auth_flow.dart';
import '../../services/auth_service.dart';
import '../../services/backend_errors.dart';
import '../../theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import 'auth_layout.dart';
import 'log_in_screen.dart';

/// Shown right after Sign Up when Supabase needs the email confirmed.
///
/// Instead of sending the new user to Log In (they just typed those exact
/// details), this screen waits and signs in by itself as soon as the link is
/// confirmed: in this browser, another tab, or on another device. The
/// password only lives in memory here, is never stored, and is dropped when
/// the screen closes.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  // Gentle enough to stay under Supabase's sign-in rate limit.
  static const _pollEvery = Duration(seconds: 10);
  static const _giveUpAfter = Duration(minutes: 15);

  Timer? _timer;
  final _codeController = TextEditingController();
  bool _verifying = false;
  final _started = DateTime.now();
  bool _checking = false;
  bool _resending = false;
  bool _gaveUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_pollEvery, (_) => _check(silent: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  /// Coming back to this tab/app (usually right after tapping the email
  /// link) checks straight away instead of waiting for the next tick.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(silent: true);
  }

  Future<void> _check({required bool silent}) async {
    if (_checking || !mounted) return;
    if (DateTime.now().difference(_started) > _giveUpAfter) {
      _timer?.cancel();
      if (!_gaveUp) setState(() => _gaveUp = true);
      return;
    }
    // Already signed in another way (e.g. the link opened in another tab).
    if (AuthService.isSignedIn) {
      _timer?.cancel();
      await AuthFlow.enterApp();
      return;
    }
    setState(() => _checking = true);
    try {
      final ok = await AuthService.trySignInAfterConfirm(
        email: widget.email,
        password: widget.password,
      );
      if (ok) {
        _timer?.cancel();
        await AuthFlow.enterApp();
        return;
      }
      if (!silent) _snack('Not confirmed yet. Tap the link in your email first.');
    } on BackendException catch (e) {
      if (!silent) _snack(e.message);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  /// Main path: type the 6-digit code from the email. No link, no new tab.
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (_verifying) return;
    if (code.length < 6) {
      _snack('Enter the 6-digit code from your email.');
      return;
    }
    setState(() => _verifying = true);
    try {
      await AuthService.verifySignupCode(email: widget.email, code: code);
      _timer?.cancel();
      await AuthFlow.enterApp();
    } on BackendException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await AuthService.resendConfirmation(widget.email);
      _snack('Sent! Check your inbox (and spam) again.');
    } on BackendException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToLogIn() {
    Navigator.of(context).pushReplacement(
      AppPageRoute<void>(builder: (_) => const LogInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AuthLayout(
      title: 'Check your email',
      subtitle: 'We sent a 6-digit code to\n${widget.email}',
      showAvatar: true,
      footer: AuthFooterLink(
        prompt: 'Confirmed on another device?',
        action: 'Log In',
        onTap: _goToLogIn,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the 6-digit code from the email. '
            'You can also just tap the link in it.',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            label: '6-digit code',
            showLabel: false,
            prefixIcon: Icons.pin_outlined,
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verifyCode(),
          ),
          const SizedBox(height: Spacing.md),
          PrimaryButton(
            label: _verifying ? 'Verifying…' : 'Verify',
            onPressed: _verifying ? null : _verifyCode,
          ),
          const SizedBox(height: Spacing.sm),
          SecondaryButton(
            label: _resending ? 'Sending…' : 'Resend email',
            onPressed: _resending ? null : _resend,
          ),
        ],
      ),
    );
  }
}