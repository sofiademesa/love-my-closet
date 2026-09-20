import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'screens/onboarding/onboarding_flow.dart';
import 'theme.dart';

void main() {
  runApp(
    // DevicePreview draws a phone frame around the app so it is judged at the
    // size it was designed for. It stays ON in the deployed build on purpose.
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love My Closet',
      debugShowCheckedModeBanner: false,

      // These two lines make the DevicePreview toolbar actually change the
      // app. Keep them.
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: appTheme,

      // Onboarding 1 -> Onboarding 2 -> Main Landing Page, then
      // Create Account / Log In / Forgot Password.
      home: const OnboardingFlow(),
    );
  }
}