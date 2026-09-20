// Widget tests for the onboarding flow. Run them with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';

/// Phone-sized surface (390 x 844 logical px) like the mockup.
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('onboarding walks through to the landing page', (tester) async {
    usePhoneSize(tester);
    // Build MyApp directly (not the DevicePreview wrapper).
    await tester.pumpWidget(const MyApp());

    // Onboarding 1
    expect(find.textContaining('nothing to wear'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Onboarding 2
    expect(find.textContaining('love your closet'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Main Landing Page
    expect(find.text('Love My Closet'), findsOneWidget);
    expect(find.text('MADE TO BE LOVED AGAIN'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('landing page opens Create Account and Log In', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(const MyApp());

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);

    // Footer link swaps to Log In.
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    // Log In -> Forgot Password -> back.
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send Reset Link'), findsOneWidget);

    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}