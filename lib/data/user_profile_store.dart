import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/backend_errors.dart';
import '../services/supabase_config.dart';

/// Single source of truth for the signed-in user's profile (display name,
/// email, bio) and a couple of closet-wide preferences, shared by every
/// screen that shows or edits them: Home's greeting, Closet's header,
/// Profile, and Edit Profile.
///
/// Backed by the Supabase `profiles` table (one row per account, created
/// automatically at sign-up). The email comes from Supabase Auth itself.
/// Same singleton + [ChangeNotifier] pattern as [OutfitStore].
class UserProfileStore extends ChangeNotifier {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  static const hiddenGemsOptions = ['7 days', '14 days', '30 days', '60 days', '90 days'];

  String _displayName = '';
  String _bio = '';
  bool _notificationsEnabled = true;
  int _hiddenGemsDays = 30;

  /// Falls back to the start of the email address until a name is set.
  String get displayName {
    if (_displayName.isNotEmpty) return _displayName;
    final local = email.split('@').first;
    return local.isEmpty ? 'My' : local;
  }

  String get email => AuthService.currentUser?.email ?? '';
  String get bio => _bio;
  bool get notificationsEnabled => _notificationsEnabled;
  String get hiddenGemsThreshold => '$_hiddenGemsDays days';
  int get hiddenGemsThresholdDays => _hiddenGemsDays;

  Future<void> load() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;
    try {
      final existing = await supabase
          .from('profiles')
          .select('display_name, bio, notifications_enabled, hidden_gems_threshold_days')
          .eq('id', uid)
          .maybeSingle();
      // Accounts created before the sign-up trigger existed get a row now.
      final Map<String, dynamic> row = existing ?? await supabase
          .from('profiles')
          .upsert({
            'id': uid,
            'display_name': (AuthService.currentUser?.userMetadata?['display_name'] as String?) ?? '',
          })
          .select('display_name, bio, notifications_enabled, hidden_gems_threshold_days')
          .single();
      _displayName = (row['display_name'] as String?) ?? '';
      _bio = (row['bio'] as String?) ?? '';
      _notificationsEnabled = (row['notifications_enabled'] as bool?) ?? true;
      _hiddenGemsDays = (row['hidden_gems_threshold_days'] as num?)?.toInt() ?? 30;
    } catch (e) {
      debugPrint('[Love My Closet] profile load failed: ${friendlyError(e)}');
    }
    notifyListeners();
  }

  /// Forget everything (on log out) so the next user never sees it.
  void clear() {
    _displayName = '';
    _bio = '';
    _notificationsEnabled = true;
    _hiddenGemsDays = 30;
    notifyListeners();
  }

  /// Saves whichever fields are provided (from Edit Profile's Save). A
  /// blank name is ignored so the app never ends up with an empty label
  /// wherever the name is shown. Returns true when an email change was
  /// requested (Supabase emails a confirmation link before it applies).
  /// Throws [BackendException] if saving fails.
  Future<bool> updateProfile({String? displayName, String? email, String? bio}) async {
    final changes = <String, dynamic>{};
    if (displayName != null && displayName.trim().isNotEmpty) {
      changes['display_name'] = displayName.trim();
    }
    if (bio != null) changes['bio'] = bio.trim();
    if (changes.isNotEmpty) await _save(changes);
    if (changes.containsKey('display_name')) _displayName = changes['display_name'] as String;
    if (changes.containsKey('bio')) _bio = changes['bio'] as String;
    notifyListeners();

    final newEmail = email?.trim() ?? '';
    if (newEmail.isNotEmpty && newEmail.toLowerCase() != this.email.toLowerCase()) {
      await AuthService.requestEmailChange(newEmail);
      return true;
    }
    return false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final before = _notificationsEnabled;
    _notificationsEnabled = value;
    notifyListeners();
    try {
      await _save({'notifications_enabled': value});
    } catch (_) {
      _notificationsEnabled = before;
      notifyListeners();
    }
  }

  Future<void> setHiddenGemsThreshold(String value) async {
    final days = int.tryParse(value.split(' ').first);
    if (days == null) return;
    final before = _hiddenGemsDays;
    _hiddenGemsDays = days;
    notifyListeners();
    try {
      await _save({'hidden_gems_threshold_days': days});
    } catch (_) {
      _hiddenGemsDays = before;
      notifyListeners();
    }
  }

  Future<void> _save(Map<String, dynamic> changes) async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) throw const BackendException('You’ve been logged out. Please log in again.');
    try {
      await supabase.from('profiles').update(changes).eq('id', uid);
    } catch (e) {
      throw BackendException(friendlyError(e));
    }
  }
}