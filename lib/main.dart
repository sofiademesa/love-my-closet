import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'animations/app_motion.dart';
import 'data/accessibility_store.dart';
import 'data/app_data.dart';
import 'screens/onboarding/log_in_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/onboarding/set_new_password_screen.dart';
import 'services/auth_flow.dart';
import 'services/auth_service.dart';
import 'services/supabase_config.dart';
import 'theme.dart';
import 'widgets/heart_avatar.dart';
import 'widgets/mouse_drag_scroll_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // DevicePreview draws a phone frame around the app so it is judged at the
    // size it was designed for. It stays ON in the deployed build on purpose.
    DevicePreview(
      enabled: true,
      // Starts on a splash while the session is restored (see StartupScreen),
      // so a signed-in user never sees Log In flash by first.
      builder: (context) => const MyApp(home: StartupScreen()),
    ),
  );
}

/// Shown for the moment it takes to connect to Supabase and work out who is
/// signed in, then replaced by Home or onboarding:
///
/// - remembered session (Remember me / new account) -> Home
/// - opened from the email-verification link -> Supabase turns the link into
///   a session -> Home, no need to log in again
/// - no session, or explicitly logged out -> onboarding
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Read the address bar before Supabase starts: once it has used an email
    // link's parameters it removes them.
    final openedFromEmailLink = AuthFlow.isAuthCallback(Uri.base);
    final linkError = AuthFlow.callbackError(Uri.base);

    var connected = false;
    try {
      // Restores a saved session and, on the verification / reset link,
      // exchanges the link's code for a session before returning.
      connected = await SupabaseConfig.initialize();
    } catch (e) {
      debugPrint('[Love My Closet] startup: $e');
    }

    final signedIn =
        connected && AuthService.isSignedIn && await AuthFlow.enterApp();
    if (!signedIn && mounted) _showSignedOutStart(openedFromEmailLink, linkError);

    if (connected) _listenToAuthEvents();
  }

  void _showSignedOutStart(bool openedFromEmailLink, String? linkError) {
    final nav = Navigator.of(context);
    nav.pushAndRemoveUntil(
      AppPageRoute<void>(builder: (_) => const OnboardingFlow()),
      (route) => false,
    );
    if (openedFromEmailLink) {
      // The link didn't produce a session. Usually it was opened in a
      // different browser than the one used to sign up: the email is
      // confirmed, but this browser can't finish the sign-in by itself.
      nav.push(AppPageRoute<void>(builder: (_) => const LogInScreen()));
      appMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            linkError != null
                ? '$linkError. Please log in, or request a new link.'
                : 'We couldn’t sign you in from that link. '
                    'If you just verified your email, please log in to continue.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeartAvatar(width: 120),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.buttonPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Started once the first screen is decided. Supabase replays earlier events
/// to a new listener, which is why every case here is safe to repeat.
void _listenToAuthEvents() {
  supabase.auth.onAuthStateChange.listen((state) {
    final nav = appNavigatorKey.currentState;
    switch (state.event) {
      case AuthChangeEvent.signedIn:
        // A sign-in the Log In / Create Account screens didn't start, e.g.
        // the verification link opened in another tab: Supabase shares the
        // new session with every open tab, so this one moves into Home too.
        // Does nothing when the sign-in is already being handled.
        unawaited(AuthFlow.enterApp());
      case AuthChangeEvent.passwordRecovery:
        nav?.push(AppPageRoute<void>(builder: (_) => const SetNewPasswordScreen()));
      case AuthChangeEvent.signedOut:
        // Log Out on Profile handles its own navigation; this covers the
        // session ending any other way (expired, revoked, logged out in
        // another tab).
        final expected = AppData.signingOut;
        final wasInApp = AppData.activeUserId != null;
        AppData.signingOut = false;
        AppData.clear();
        if (!expected && wasInApp) {
          nav?.pushAndRemoveUntil(
            AppPageRoute<void>(builder: (_) => const OnboardingFlow()),
            (route) => false,
          );
        }
      default:
        break;
    }
  }, onError: (Object e) => debugPrint('[Love My Closet] auth event error: $e'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home = const OnboardingFlow()});

  /// First screen: the startup splash in the real app; tests start straight
  /// at onboarding.
  final Widget home;

  @override
  Widget build(BuildContext context) {
    // Rebuilds whenever a setting on the Accessibility screen changes, so
    // Text Size / Reduce Motion / High Contrast take effect immediately,
    // app-wide, without needing a restart.
    return ListenableBuilder(
      listenable: AccessibilityStore.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Love My Closet',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          scaffoldMessengerKey: appMessengerKey,

          // Lets every scrollable in the app (chip rows, lists) be dragged with a
          // mouse on desktop/web, not just touch.
          scrollBehavior: const MouseDragScrollBehavior(),

          // These two lines make the DevicePreview toolbar actually change the
          // app. Keep them.
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            Widget content = DevicePreview.appBuilder(context, child);
            // Text Size: scales every Text widget in the app from one place,
            // instead of touching each screen's TextStyles.
            final store = AccessibilityStore.instance;
            content = MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(store.textSize.scale)),
              child: content,
            );
            return content;
          },

          theme: buildAppTheme(),

          // Onboarding 1 -> Onboarding 2 -> Main Landing Page, then
          // Create Account / Log In / Forgot Password.
          home: home,
        );
      },
    );
  }
}