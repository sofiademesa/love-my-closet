import '../services/auth_service.dart';
import 'closet_store.dart';
import 'outfit_store.dart';
import 'user_profile_store.dart';

/// Loads / clears every per-user store together, so switching accounts
/// never leaves the previous user's closet on screen.
class AppData {
  const AppData._();

  /// The account whose data is loaded (null when signed out). Set before
  /// loading starts, so AuthFlow.enterApp can tell a sign-in it is already
  /// handling from a new one.
  static String? get activeUserId => _activeUserId;
  static String? _activeUserId;

  /// After Log In, Sign Up (when signed in right away) or a restored session.
  static Future<void> loadForCurrentUser() async {
    final uid = AuthService.currentUser?.id;
    if (!AuthService.isSignedIn || uid == null) return;
    // A different account than the one on screen: drop the old data first.
    if (_activeUserId != null && _activeUserId != uid) clear();
    _activeUserId = uid;
    await Future.wait([
      UserProfileStore.instance.load(),
      ClosetStore.instance.load(),
      OutfitStore.instance.load(),
    ]);
    // Logged out while this was loading: don't leave that data behind.
    if (AuthService.currentUser == null) clear();
  }

  static void clear() {
    _activeUserId = null;
    ClosetStore.instance.clear();
    OutfitStore.instance.clear();
    UserProfileStore.instance.clear();
  }

  /// True while Profile → Log Out is signing out, so the global auth
  /// listener in main.dart knows the screen handles navigation itself.
  static bool signingOut = false;

  /// Profile → Log Out.
  static Future<void> signOut() async {
    // Reset by main.dart's listener once the signedOut event arrives
    // (it's delivered asynchronously, after this returns).
    signingOut = true;
    await AuthService.signOut();
    clear();
  }
}