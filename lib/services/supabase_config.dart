import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_persistence.dart';

/// Where the app finds its Supabase project.
///
/// Plain `flutter run -d chrome` works out of the box: it uses the project
/// defaults below. To point the app at a different Supabase project, pass
/// `--dart-define-from-file=env.json` (git-ignored), which overrides them.
///
/// Only the project URL and the PUBLISHABLE key belong here. Both are public
/// by design (they ship inside every web build anyway); Row Level Security in
/// supabase/migrations/ is what protects the data. The secret /
/// service_role key must NEVER be put in this file or passed to the build.
class SupabaseConfig {
  const SupabaseConfig._();

  static const _defaultUrl = 'https://ijfnzihrsjvzzcdchfbt.supabase.co';
  static const _defaultPublishableKey = 'sb_publishable_IZn-1D27xzm3ltR44ER1lg_oFGWGjtf';

  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: _defaultUrl);
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: _defaultPublishableKey,
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  /// Refuses keys that look privileged, so a copy-paste mistake fails
  /// loudly in development instead of shipping a secret to every visitor.
  static bool get _looksLikeSecretKey {
    if (publishableKey.startsWith('sb_secret_')) return true;
    // Legacy keys are JWTs: check the role inside the payload.
    final parts = publishableKey.split('.');
    if (parts.length == 3) {
      try {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        return payload.contains('"service_role"');
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Why [initialize] failed when the values WERE provided (e.g. a bad URL),
  /// so the app can say so instead of blaming missing settings.
  static String? startupError;

  /// Call once from main() before runApp. Returns false (and logs why) when
  /// the app was built without Supabase settings.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    if (!isConfigured) {
      debugPrint(
        '[Love My Closet] Supabase is not configured. Run with '
        '--dart-define-from-file=env.json (see .env.example).',
      );
      return false;
    }
    debugPrint('[Love My Closet] Connecting to Supabase at $url');
    if (_looksLikeSecretKey) {
      startupError = 'the key in env.json is a SECRET key. Use the sb_publishable_ key instead';
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY looks like a secret/service_role key. '
        'Use the publishable (anon) key in the app; never ship the secret key.',
      );
    }
    try {
      await Supabase.initialize(
        url: url,
        anonKey: publishableKey,
        authOptions: FlutterAuthClientOptions(
          // Honors the "Remember me" checkbox on Log In.
          localStorage: RememberMeLocalStorage(
            persistSessionKey:
                'sb-${Uri.parse(url).host.split('.').first}-auth-token',
          ),
        ),
      );
    } catch (e) {
      startupError ??= 'couldn’t start the connection ($e)';
      rethrow;
    }
    _initialized = true;
    startupError = null;
    return true;
  }
}

/// The shared client. Only valid after [SupabaseConfig.initialize].
SupabaseClient get supabase => Supabase.instance.client;