// Tests for sign-up / login helpers and forms.
// No network: nothing here signs anyone in. The valid-form case is left out on
// purpose because submitting it would call AuthService.signUp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';
import 'package:final_project/screens/onboarding/auth_layout.dart';
import 'package:final_project/services/auth_flow.dart';
import 'package:final_project/services/auth_service.dart';
import 'package:final_project/widgets/app_text_field.dart';

void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('Validators', () {
    test('notEmpty rejects null, empty and spaces', () {
      expect(Validators.notEmpty(null, 'msg'), 'msg');
      expect(Validators.notEmpty('', 'msg'), 'msg');
      expect(Validators.notEmpty('   ', 'msg'), 'msg');
      expect(Validators.notEmpty('Sofia', 'msg'), isNull);
    });

    test('email: empty asks for an email address', () {
      expect(Validators.email(null), 'Please enter your email address');
      expect(Validators.email('  '), 'Please enter your email address');
    });

    test('email: malformed addresses are rejected', () {
      for (final bad in ['sofia', 'sofia@', '@mail.com', 'sofia@mail', 'so fia@mail.com']) {
        expect(Validators.email(bad), 'Please enter a valid email address', reason: bad);
      }
    });

    test('email: valid addresses pass (surrounding spaces ignored)', () {
      expect(Validators.email('sofia@mail.com'), isNull);
      expect(Validators.email('  sofia@mail.com  '), isNull);
      expect(Validators.email('s.d+closet@school.edu.ph'), isNull);
    });
  });

  group('AuthFlow email-link detection', () {
    test('a normal app address is not an auth callback', () {
      expect(AuthFlow.isAuthCallback(Uri.parse('https://example.com/love-my-closet/')), false);
      expect(AuthFlow.isAuthCallback(Uri.parse('https://example.com/#/')), false);
    });

    test('code in the query is an auth callback', () {
      expect(AuthFlow.isAuthCallback(Uri.parse('https://example.com/?code=abc')), true);
    });

    test('access_token in the fragment is an auth callback', () {
      expect(
        AuthFlow.isAuthCallback(Uri.parse('https://example.com/#access_token=abc&type=signup')),
        true,
      );
    });

    test('an expired link exposes its error description', () {
      final uri = Uri.parse(
        'https://example.com/#error=access_denied&error_description=Email+link+is+invalid+or+has+expired',
      );
      expect(AuthFlow.isAuthCallback(uri), true);
      expect(AuthFlow.callbackError(uri), 'Email link is invalid or has expired');
    });

    test('no error description on a normal address', () {
      expect(AuthFlow.callbackError(Uri.parse('https://example.com/')), isNull);
    });
  });

  group('signed-out state', () {
    test('nobody is signed in when the backend is not initialized', () {
      expect(AuthService.currentUser, isNull);
      expect(AuthService.isSignedIn, false);
    });

    test('enterApp does nothing and returns false when signed out', () async {
      expect(await AuthFlow.enterApp(), false);
    });
  });

  group('password visibility (AppTextField)', () {
    Future<void> pumpField(WidgetTester tester, {bool obscure = true}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Password',
              controller: TextEditingController(text: 'secret123'),
              obscureText: obscure,
            ),
          ),
        ),
      );
    }

    bool obscured(WidgetTester tester) =>
        tester.widget<EditableText>(find.byType(EditableText)).obscureText;

    testWidgets('password is hidden by default', (tester) async {
      await pumpField(tester);
      expect(obscured(tester), true);
      expect(find.byTooltip('Show password'), findsOneWidget);
    });

    testWidgets('eye button shows then hides the password', (tester) async {
      await pumpField(tester);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(tester), false);
      expect(find.byTooltip('Hide password'), findsOneWidget);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(obscured(tester), true);
      expect(find.byTooltip('Show password'), findsOneWidget);
    });

    testWidgets('a normal field has no eye button', (tester) async {
      await pumpField(tester, obscure: false);
      expect(find.byTooltip('Show password'), findsNothing);
      expect(obscured(tester), false);
    });
  });

  group('Create Account form', () {
    /// Onboarding -> landing -> Create Account (same path as widget_test.dart).
    Future<void> openCreateAccount(WidgetTester tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(const MyApp());
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);
    }

    Future<void> tapSignUp(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
    }

    testWidgets('empty form shows every validation message', (tester) async {
      await openCreateAccount(tester);
      await tapSignUp(tester);

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Use at least 8 characters'), findsOneWidget);
    });

    testWidgets('a short password is rejected', (tester) async {
      await openCreateAccount(tester);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sofia');
      await tester.enterText(fields.at(1), 'sofia@mail.com');
      await tester.enterText(fields.at(2), '1234567'); // 7 characters
      await tester.enterText(fields.at(3), '1234567');
      await tapSignUp(tester);

      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(find.text('Please enter your name'), findsNothing);
    });

    testWidgets('mismatched confirm password is rejected', (tester) async {
      await openCreateAccount(tester);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sofia');
      await tester.enterText(fields.at(1), 'sofia@mail.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password124');
      await tapSignUp(tester);

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('Use at least 8 characters'), findsNothing);
    });

    testWidgets('an invalid email is rejected', (tester) async {
      await openCreateAccount(tester);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sofia');
      await tester.enterText(fields.at(1), 'not-an-email');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');
      await tapSignUp(tester);

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('both password fields have their own eye button', (tester) async {
      await openCreateAccount(tester);
      expect(find.byTooltip('Show password'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Show password').first);
      await tester.pump();

      expect(find.byTooltip('Show password'), findsOneWidget);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });
  });
}