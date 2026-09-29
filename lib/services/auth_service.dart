import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend_errors.dart';
import 'session_persistence.dart';
import 'supabase_config.dart';

/// Result of Create Account.
enum SignUpOutcome {
  /// Signed in straight away (email confirmation is off in Supabase).
  signedIn,

  /// Account created; Supabase emailed a confirmation link first.
  confirmEmail,
}

/// Thin wrapper over Supabase Auth used by the onboarding and profile
/// screens. Every method throws [BackendException] with a friendly message.
class AuthService {
  const AuthService._();

  static User? get currentUser =>
      SupabaseConfig.isInitialized ? supabase.auth.currentUser : null;

  static bool get isSignedIn =>
      SupabaseConfig.isInitialized && supabase.auth.currentSession != null;

  static void _requireBackend() {
    if (!SupabaseConfig.isInitialized) {
      if (!SupabaseConfig.isConfigured) {
        // The build didn't receive env.json at all.
        throw const BackendException(
          'The app was started without its server settings. Stop it and run: '
          'flutter run -d chrome --web-port 5000 --dart-define-from-file=env.json',
        );
      }
      throw BackendException(
        'The server settings were found, but the app '
        '${SupabaseConfig.startupError ?? 'couldn’t connect'}. '
        'Check env.json and your internet connection.',
      );
    }
  }

  /// Create Account. The database trigger creates the matching profile row
  /// from the metadata sent here.
  static Future<SignUpOutcome> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _requireBackend();
    final name = fullName.trim();
    try {
      RememberMeLocalStorage.rememberMe = true;
      final res = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': name,
          'display_name': name.split(RegExp(r'\s+')).first,
        },
        emailRedirectTo: _webRedirectUrl,
      );
      // With confirmation on, Supabase answers a sign-up for an existing
      // email with a user that has no identities instead of an error.
      final identities = res.user?.identities;
      if (identities != null && identities.isEmpty) {
        throw const BackendException(
          'An account with this email already exists. Try logging in.',
        );
      }
      return res.session != null ? SignUpOutcome.signedIn : SignUpOutcome.confirmEmail;
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _requireBackend();
    try {
      RememberMeLocalStorage.rememberMe = rememberMe;
      await supabase.auth.signInWithPassword(email: email.trim(), password: password);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  static Future<void> signOut() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await supabase.auth.signOut();
    } catch (e) {
      // Even if the server call fails, the local session is cleared.
      debugPrint('[Love My Closet] sign-out: $e');
    }
  }

  /// Forgot Password: emails a reset link that opens the app, which then
  /// shows the Set New Password screen (see main.dart).
  static Future<void> sendPasswordReset(String email) async {
    _requireBackend();
    try {
      await supabase.auth.resetPasswordForEmail(email.trim(), redirectTo: _webRedirectUrl);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  /// Sets a new password for the signed-in (or password-recovery) session.
  static Future<void> updatePassword(String newPassword) async {
    _requireBackend();
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  /// Starts an email change. Supabase sends a confirmation link and only
  /// switches the address once it's clicked.
  static Future<void> requestEmailChange(String newEmail) async {
    _requireBackend();
    try {
      await supabase.auth.updateUser(
        UserAttributes(email: newEmail.trim()),
        emailRedirectTo: _webRedirectUrl,
      );
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }

  /// Where email links (confirm, reset password) send the user back to: the
  /// page the web app is served from, e.g. https://you.github.io/love-my-closet/.
  /// Must be listed under Authentication > URL Configuration > Redirect URLs.
  /// On mobile, null falls back to the Site URL set in the dashboard.
  static String? get _webRedirectUrl {
    if (!kIsWeb) return null;
    final base = Uri.base;
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: base.path,
    ).toString();
  }
}