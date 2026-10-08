// Tests for the profile + accessibility stores.

import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/data/accessibility_store.dart';
import 'package:final_project/data/user_profile_store.dart';
import 'package:final_project/services/backend_errors.dart';

void main() {
  final profile = UserProfileStore.instance;
  final a11y = AccessibilityStore.instance;

  setUp(() {
    profile.clear();
    a11y.setTextSize(TextSizeOption.standard);
    a11y.setReduceMotion(false);
    a11y.setHighContrast(false);
  });

  group('UserProfileStore', () {
    test('display name falls back to "My" when no name and no email', () {
      expect(profile.displayName, 'My');
      expect(profile.email, '');
    });

    test('defaults after clear()', () {
      expect(profile.bio, '');
      expect(profile.notificationsEnabled, true);
      expect(profile.hiddenGemsThreshold, '30 days');
      expect(profile.hiddenGemsThresholdDays, 30);
    });

    test('clear() notifies listeners', () {
      var calls = 0;
      void listener() => calls++;
      profile.addListener(listener);
      profile.clear();
      profile.removeListener(listener);
      expect(calls, 1);
    });

    test('a blank name is ignored (no save, no error, name unchanged)', () async {
      final emailChangeRequested = await profile.updateProfile(displayName: '   ');
      expect(emailChangeRequested, false);
      expect(profile.displayName, 'My');
    });

    test('saving a name while logged out fails and keeps the old name', () async {
      await expectLater(
        profile.updateProfile(displayName: 'Sofia'),
        throwsA(
          isA<BackendException>().having((e) => e.message, 'message', contains('logged out')),
        ),
      );
      expect(profile.displayName, 'My');
    });

    test('saving a bio while logged out fails and keeps the old bio', () async {
      await expectLater(
        profile.updateProfile(bio: 'I love thrifting'),
        throwsA(isA<BackendException>()),
      );
      expect(profile.bio, '');
    });

    test('notifications toggle rolls back when saving fails', () async {
      var calls = 0;
      void listener() => calls++;
      profile.addListener(listener);

      await profile.setNotificationsEnabled(false);
      profile.removeListener(listener);

      expect(profile.notificationsEnabled, true); // rolled back
      expect(calls, 2); // optimistic change + rollback
    });

    test('hidden gems threshold rolls back when saving fails', () async {
      await profile.setHiddenGemsThreshold('60 days');
      expect(profile.hiddenGemsThresholdDays, 30);
    });

    test('hidden gems threshold ignores text that is not a number', () async {
      await profile.setHiddenGemsThreshold('soon');
      expect(profile.hiddenGemsThresholdDays, 30);
    });

    test('every hidden gems option is a number of days the store can parse', () {
      for (final option in UserProfileStore.hiddenGemsOptions) {
        expect(int.tryParse(option.split(' ').first), isNotNull, reason: option);
      }
    });
  });

  group('AccessibilityStore', () {
    test('text size scales are small < default < large', () {
      expect(TextSizeOption.small.scale, 0.9);
      expect(TextSizeOption.standard.scale, 1.0);
      expect(TextSizeOption.large.scale, 1.15);
    });

    test('text size labels match the Accessibility screen', () {
      expect(TextSizeOption.small.label, 'Small');
      expect(TextSizeOption.standard.label, 'Default');
      expect(TextSizeOption.large.label, 'Large');
    });

    test('changing a setting notifies listeners', () {
      var calls = 0;
      void listener() => calls++;
      a11y.addListener(listener);

      a11y.setTextSize(TextSizeOption.large);
      a11y.setReduceMotion(true);
      a11y.setHighContrast(true);
      a11y.removeListener(listener);

      expect(calls, 3);
      expect(a11y.textSize, TextSizeOption.large);
      expect(a11y.reduceMotion, true);
      expect(a11y.highContrast, true);
    });

    test('setting the same value again does not notify', () {
      var calls = 0;
      void listener() => calls++;
      a11y.addListener(listener);

      a11y.setTextSize(TextSizeOption.standard);
      a11y.setReduceMotion(false);
      a11y.setHighContrast(false);
      a11y.removeListener(listener);

      expect(calls, 0);
    });

    test('turning a setting back off returns to the default', () {
      a11y.setReduceMotion(true);
      a11y.setReduceMotion(false);
      const normal = Duration(milliseconds: 250);
      expect(kMotionDuration(normal), normal);
    });
  });
}