import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'data/accessibility_store.dart';
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
    // Rebuilds whenever a setting on the Accessibility screen changes, so
    // Text Size / Reduce Motion / High Contrast take effect immediately,
    // app-wide, without needing a restart.
    return ListenableBuilder(
      listenable: AccessibilityStore.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Love My Closet',
          debugShowCheckedModeBanner: false,

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
          home: const OnboardingFlow(),
        );
      },
    );
  }
}