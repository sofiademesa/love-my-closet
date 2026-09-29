import 'dart:async';

import 'package:flutter/material.dart';

import '../animations/app_motion.dart';
import '../data/app_data.dart';
import '../screens/home/home_screen.dart';
import 'auth_service.dart';

/// Lets auth events (email-verification link, password-reset link, session
/// expired) navigate from outside any screen.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Lets startup show a message before any screen has its own Scaffold.
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Moves a signed-in user into the app (Home).
class AuthFlow {
  const AuthFlow._();

  /// Loads the signed-in user's data and shows Home. Startup, Log In,
  /// Create Account and the auth listener in main.dart can all react to the
  /// same sign-in: whichever gets there first does the work and the others
  /// do nothing, so Home is never pushed twice.
  ///
  /// Returns false only when nobody is signed in (anymore).
  static Future<bool> enterApp() async {
    final uid = AuthService.currentUser?.id;
    if (!AuthService.isSignedIn || uid == null) return false;
    if (AppData.activeUserId == uid) return true; // already in (or on the way)
    try {
      // Claims [uid] synchronously, before its first await.
      await AppData.loadForCurrentUser().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Slow network: stores keep loading in the background.
    } catch (e) {
      debugPrint('[Love My Closet] loading data: $e');
    }
    // Signed out (or someone else signed in) while the data was loading.
    if (AppData.activeUserId != uid) return AppData.activeUserId != null;
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      AppPageRoute<void>(builder: (_) => const HomeScreen()),
      (route) => false,
    );
    return true;
  }

  /// True when [uri] is Supabase sending the browser back from an email link
  /// (confirm sign-up, reset password): a PKCE `code` or an error, in the
  /// query or the fragment. Mirrors supabase_flutter's own check.
  static bool isAuthCallback(Uri uri) {
    final params = _params(uri);
    return const ['code', 'access_token', 'error', 'error_code', 'error_description']
        .any(params.containsKey);
  }

  /// Supabase's explanation when an email link failed (e.g. it expired).
  static String? callbackError(Uri uri) => _params(uri)['error_description'];

  static Map<String, String> _params(Uri uri) {
    final params = <String, String>{...uri.queryParameters};
    try {
      params.addAll(Uri.splitQueryString(uri.fragment));
    } catch (_) {
      // A normal route fragment like "#/" is not key=value pairs.
    }
    return params;
  }
}