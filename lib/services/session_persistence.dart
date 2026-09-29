import 'package:supabase_flutter/supabase_flutter.dart';

/// Session storage that honors the "Remember me" checkbox on Log In.
///
/// - Remember me ON: the session is saved like normal (browser local
///   storage on web, shared preferences on mobile) and survives a refresh or
///   app restart.
/// - Remember me OFF: the session only lives in memory, so closing the tab or
///   app signs Sofia out. Anything previously saved is wiped.
///
/// Only the session tokens go through here; no closet data is cached.
class RememberMeLocalStorage extends LocalStorage {
  RememberMeLocalStorage({required String persistSessionKey})
      : _saved = SharedPreferencesLocalStorage(persistSessionKey: persistSessionKey);

  final SharedPreferencesLocalStorage _saved;
  String? _inMemory;

  /// Set by Log In just before signing in. Sign Up keeps the default (on).
  static bool rememberMe = true;

  @override
  Future<void> initialize() async {
    await _saved.initialize();
    // A session saved on an earlier visit means Remember me was on then.
    if (await _saved.hasAccessToken()) rememberMe = true;
  }

  @override
  Future<bool> hasAccessToken() async =>
      rememberMe ? _saved.hasAccessToken() : _inMemory != null;

  @override
  Future<String?> accessToken() async =>
      rememberMe ? _saved.accessToken() : _inMemory;

  @override
  Future<void> removePersistedSession() async {
    _inMemory = null;
    await _saved.removePersistedSession();
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    if (rememberMe) {
      _inMemory = null;
      await _saved.persistSession(persistSessionString);
    } else {
      _inMemory = persistSessionString;
      await _saved.removePersistedSession();
    }
  }
}