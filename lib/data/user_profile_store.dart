import 'package:flutter/foundation.dart';

/// Single source of truth for the signed-in user's profile (display name,
/// email, bio) and a couple of closet-wide preferences, shared by every
/// screen that shows or edits them: Home's greeting, Closet's header,
/// Profile, and Edit Profile.
///
/// This project has no dependency-injection or state-management package, so
/// this is a plain singleton — reached via [UserProfileStore.instance] —
/// backed by [ChangeNotifier], same pattern as [OutfitStore]. Any screen
/// that stays on-screen while the profile changes (Home, Closet, Calendar,
/// Outfit Builder, Profile) adds a listener and rebuilds.
class UserProfileStore extends ChangeNotifier {
  UserProfileStore._();

  static final UserProfileStore instance = UserProfileStore._();

  static const hiddenGemsOptions = ['7 days', '14 days', '30 days', '60 days', '90 days'];

  String _displayName = 'Sofia';
  String _email = 'sofiardmesa@gmail.com';
  String _bio = 'Pink, polka dots & good outfits. \u2661';
  bool _notificationsEnabled = true;
  String _hiddenGemsThreshold = '30 days';

  String get displayName => _displayName;
  String get email => _email;
  String get bio => _bio;
  bool get notificationsEnabled => _notificationsEnabled;
  String get hiddenGemsThreshold => _hiddenGemsThreshold;

  /// Updates whichever fields are provided (from Edit Profile's Save). A
  /// blank name is ignored so the app never ends up with an empty label
  /// wherever the name is shown.
  void updateProfile({String? displayName, String? email, String? bio}) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      _displayName = displayName.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      _email = email.trim();
    }
    if (bio != null) {
      _bio = bio.trim();
    }
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setHiddenGemsThreshold(String value) {
    _hiddenGemsThreshold = value;
    notifyListeners();
  }
}