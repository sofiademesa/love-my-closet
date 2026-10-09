// Tests for the background-removal flow. The real ONNX model is never run:
// AddingItemPhotoScreen accepts a fake photo source and a fake remover.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:final_project/screens/closet/adding_item_photo_screen.dart';
import 'package:final_project/screens/closet/take_photo_screen.dart';
import 'package:final_project/services/live_camera.dart';
import 'package:final_project/services/background_removal_service.dart';
import 'package:final_project/services/image_bytes.dart';
import 'package:final_project/services/photo_source_service.dart';
import 'package:final_project/theme.dart';

// A real 1x1 PNG so Image.memory has valid bytes.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

/// Pretends to be the gallery.
class FakePhotoSource extends PhotoSourceService {
  Uint8List? result;
  PhotoSourceException? error;
  int calls = 0;
  ImageSource? lastSource;

  @override
  Future<Uint8List?> pick(ImageSource source) async {
    calls++;
    lastSource = source;
    if (error != null) throw error!;
    return result;
  }
}

/// Pretends to be the ONNX remover. Set [gate] to hold it in "processing".
class FakeRemover extends BackgroundRemovalService {
  Uint8List? result;
  Object? error;
  Completer<Uint8List>? gate;
  int calls = 0;
  int prepareCalls = 0;

  @override
  void prepare() => prepareCalls++;

  @override
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  }) async {
    calls++;
    if (gate != null) return gate!.future;
    if (error != null) throw error!;
    return result!;
  }
}

void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('BackgroundRemovalService (no UI)', () {
    test('the default remover fails with a clear message off-web', () async {
      // In `flutter test` there is no on-device remover, so it must refuse
      // instead of silently doing something else.
      final remover = createBackgroundRemover();
      await expectLater(
        remover.removeBackground(_png),
        throwsA(
          isA<BackgroundRemovalException>()
              .having((e) => e.message, 'message', contains("isn't available")),
        ),
      );
    });

    test('a fake remover can succeed and report progress', () async {
      final seen = <BackgroundRemovalStage>[];
      final remover = _ProgressRemover(_png);
      final out = await remover.removeBackground(
        _png,
        onProgress: (stage, fraction) => seen.add(stage),
      );
      expect(isPng(out), true);
      expect(seen, [BackgroundRemovalStage.preparing, BackgroundRemovalStage.removing]);
    });

    test('exception carries a message that is safe to show', () {
      const e = BackgroundRemovalException('Nope');
      expect(e.message, 'Nope');
      expect(e.toString(), contains('Nope'));
    });

    test('isPng recognises PNG bytes and rejects others', () {
      expect(isPng(_png), true);
      expect(isPng(Uint8List.fromList([1, 2, 3])), false);
      expect(isPng(Uint8List(0)), false);
    });
  });

  group('AddingItemPhotoScreen', () {
    late FakePhotoSource photos;
    late FakeRemover remover;
    late Uint8List original;
    late Uint8List cutout;

    ProcessedPhoto? popped;
    bool closed = false;

    // Fake camera for Take Photo.
    Uint8List? cameraResult;
    int cameraCalls = 0;

    setUp(() {
      original = Uint8List.fromList(_png);
      cutout = Uint8List.fromList(_png);
      photos = FakePhotoSource()..result = original;
      remover = FakeRemover()..result = cutout;
      popped = null;
      closed = false;
      cameraResult = Uint8List.fromList(_png);
      cameraCalls = 0;
    });

    /// Opens the screen from a host page so we can see what it pops.
    Future<void> openScreen(WidgetTester tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    popped = await Navigator.of(context).push<ProcessedPhoto>(
                      MaterialPageRoute(
                        builder: (_) => AddingItemPhotoScreen(
                          photoSource: photos,
                          backgroundRemover: remover,
                          takePhoto: (_) async {
                            cameraCalls++;
                            return cameraResult;
                          },
                        ),
                      ),
                    );
                    closed = true;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    /// Switches the toggle to Choose from Gallery, then taps the photo box.
    Future<void> pickFromGallery(WidgetTester tester) async {
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap to add a photo'));
    }

    /// Lets queued async work (fake picker, fake remover) finish.
    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('starts empty: asks for a photo, nothing processed', (tester) async {
      await openScreen(tester);

      expect(find.text('Tap to add a photo'), findsOneWidget);
      expect(find.text('Take a photo or pick one from your gallery.'), findsOneWidget);
      expect(remover.calls, 0);
    });

    testWidgets('toggle offers Take Photo (default) and Choose from Gallery', (tester) async {
      await openScreen(tester);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);

      // Picking a mode alone opens nothing.
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();
      expect(photos.calls, 0);
      expect(cameraCalls, 0);
    });

    testWidgets('Take Photo uses the camera, then removes the background', (tester) async {
      await openScreen(tester);

      await tester.tap(find.text('Tap to add a photo'));
      await settle(tester);
      await tester.pumpAndSettle();

      expect(cameraCalls, 1);
      expect(photos.calls, 0); // gallery not opened
      expect(remover.calls, 1);
      expect(find.text('Background removed! Looks great.'), findsOneWidget);
      expect(find.text('Use Photo'), findsOneWidget);
    });

    testWidgets('closing the camera without a photo changes nothing', (tester) async {
      cameraResult = null;
      await openScreen(tester);

      await tester.tap(find.text('Tap to add a photo'));
      await settle(tester);

      expect(cameraCalls, 1);
      expect(remover.calls, 0);
      expect(find.text('Take a photo or pick one from your gallery.'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
    });

    testWidgets('Choose from Gallery asks the gallery, not the camera', (tester) async {
      await openScreen(tester);
      await pickFromGallery(tester);
      await settle(tester);
      expect(photos.lastSource, ImageSource.gallery);
      expect(cameraCalls, 0);
    });

    testWidgets('image selected -> processing state -> success', (tester) async {
      remover.gate = Completer<Uint8List>();
      await openScreen(tester);

      await pickFromGallery(tester);
      await settle(tester);

      // Processing: overlay message is on screen, buttons are locked.
      expect(photos.calls, 1);
      expect(remover.calls, 1);
      expect(find.text('Removing the background…'), findsWidgets);
      expect(find.text('Background removed! Looks great.'), findsNothing);

      remover.gate!.complete(cutout);
      await settle(tester);
      await tester.pumpAndSettle();

      // Success.
      expect(find.text('Background removed! Looks great.'), findsOneWidget);
      expect(find.text('Use Photo'), findsOneWidget);
      expect(find.text('Preview background'), findsOneWidget);
    });

    testWidgets('warms up the remover while the picker is open', (tester) async {
      await openScreen(tester);
      await pickFromGallery(tester);
      await settle(tester);
      expect(remover.prepareCalls, 1);
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      photos.result = null; // user cancelled
      await openScreen(tester);

      await pickFromGallery(tester);
      await settle(tester);

      expect(find.text('Take a photo or pick one from your gallery.'), findsOneWidget);
      expect(remover.calls, 0);
    });

    testWidgets('picker error shows its message and allows trying again', (tester) async {
      photos.error = const PhotoSourceException('Photo access is turned off.');
      await openScreen(tester);

      await pickFromGallery(tester);
      await settle(tester);

      expect(find.text('Photo access is turned off.'), findsOneWidget);
      expect(find.text('Tap to add a photo'), findsOneWidget);
      expect(remover.calls, 0);
    });

    testWidgets('removal error shows the message and offers Remove Background', (tester) async {
      remover.error = const BackgroundRemovalException("Couldn't cut this one out.");
      await openScreen(tester);

      await pickFromGallery(tester);
      await settle(tester);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't cut this one out."), findsOneWidget);
      expect(find.text('Remove Background'), findsOneWidget);
      expect(find.text('Use Photo'), findsNothing);
    });

    testWidgets('an unexpected error shows a generic friendly message', (tester) async {
      remover.error = StateError('boom');
      await openScreen(tester);

      await pickFromGallery(tester);
      await settle(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong removing the background. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('retry after an error succeeds', (tester) async {
      remover.error = const BackgroundRemovalException('Try again');
      await openScreen(tester);
      await pickFromGallery(tester);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('Remove Background'), findsOneWidget);

      remover.error = null;
      await tester.tap(find.text('Remove Background'));
      await settle(tester);
      await tester.pumpAndSettle();

      expect(remover.calls, 2);
      expect(find.text('Background removed! Looks great.'), findsOneWidget);
      expect(find.text('Use Photo'), findsOneWidget);
    });

    testWidgets('Undo goes back to the original photo', (tester) async {
      await openScreen(tester);
      await pickFromGallery(tester);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('Use Photo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Ready to remove the background.'), findsOneWidget);
      expect(find.text('Remove Background'), findsOneWidget);
      expect(find.text('Use Photo'), findsNothing);
    });

    testWidgets('Use Photo hands back the cutout and closes the screen', (tester) async {
      await openScreen(tester);
      await pickFromGallery(tester);
      await settle(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use Photo'));
      await tester.pumpAndSettle();

      expect(closed, true);
      expect(popped, isNotNull);
      expect(popped!.bytes, same(cutout)); 
      expect(popped!.backgroundColorName, 'White');
    });

    testWidgets('back button closes without a photo', (tester) async {
      await openScreen(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      expect(closed, true);
      expect(popped, isNull);
    });
  });

  group('TakePhotoScreen', () {
    testWidgets('shows the error and the browser detail when the camera fails', (tester) async {
      usePhoneSize(tester);
      final camera = FakeLiveCamera()
        ..openError = const LiveCameraException(
          "Your camera couldn't start.",
          detail: 'NotReadableError: Could not start video source',
        );
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: TakePhotoScreen(camera: camera),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text("Your camera couldn't start."), findsOneWidget);
      expect(find.text('NotReadableError: Could not start video source'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Try Again succeeds once the camera is free.
      camera.openError = null;
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('the shutter hands back the photo and turns the camera off', (tester) async {
      usePhoneSize(tester);
      final camera = FakeLiveCamera()..photo = Uint8List.fromList(_png);
      Uint8List? popped;
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                popped = await Navigator.of(context).push<Uint8List>(
                  MaterialPageRoute(builder: (_) => TakePhotoScreen(camera: camera)),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Take photo',
      ));
      await tester.pumpAndSettle();

      expect(popped, isNotNull);
      expect(camera.closeCalls, greaterThanOrEqualTo(1));
    });
  });
}

/// Pretends to be the browser camera.
class FakeLiveCamera implements LiveCamera {
  LiveCameraException? openError;
  Uint8List? photo;
  int closeCalls = 0;

  @override
  Future<int> open() async {
    if (openError != null) throw openError!;
    return 1;
  }

  @override
  Future<int> switchCamera() async => 1;

  @override
  Future<Uint8List> capture() async => photo!;

  @override
  void close() => closeCalls++;

  @override
  Widget buildPreview() => const SizedBox.expand();
}

class _ProgressRemover extends BackgroundRemovalService {
  _ProgressRemover(this._out);
  final Uint8List _out;

  @override
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  }) async {
    onProgress?.call(BackgroundRemovalStage.preparing, 0.5);
    onProgress?.call(BackgroundRemovalStage.removing, null);
    return _out;
  }
}