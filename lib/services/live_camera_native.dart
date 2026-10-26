import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import 'live_camera.dart';

/// Android uses the phone's real camera (the `camera` package). Other
/// non-web platforms (iOS, desktop, `flutter test`) aren't set up yet.
LiveCamera createLiveCamera() =>
    Platform.isAndroid ? _NativeLiveCamera() : _UnavailableLiveCamera();

class _NativeLiveCamera implements LiveCamera {
  List<CameraDescription> _cameras = const [];
  int _index = 0;
  CameraController? _controller;

  @override
  Future<int> open() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      throw _friendly(e);
    }
    if (_cameras.isEmpty) {
      throw const LiveCameraException(
        'No camera was found. Try choosing from your gallery instead.',
      );
    }
    // Back camera first, like the web version.
    final back = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    _index = back >= 0 ? back : 0;
    await _start();
    return _cameras.length;
  }

  @override
  Future<int> switchCamera() async {
    if (_cameras.length < 2) return _cameras.length;
    _index = (_index + 1) % _cameras.length;
    await _start();
    return _cameras.length;
  }

  Future<void> _start() async {
    final old = _controller;
    _controller = null;
    await old?.dispose();
    final controller = CameraController(
      _cameras[_index],
      // Plenty for a clothing photo, and keeps files well under 25 MB.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      throw _friendly(e);
    }
    _controller = controller;
  }

  @override
  Future<Uint8List> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const LiveCameraException("The camera isn't ready yet. Please try again.");
    }
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      // The camera package saves a temporary file; it isn't needed now.
      try {
        await File(file.path).delete();
      } catch (_) {}
      return bytes;
    } on CameraException catch (e) {
      throw LiveCameraException("Couldn't take the photo. Please try again.", detail: e.description);
    }
  }

  @override
  void close() {
    final old = _controller;
    _controller = null;
    old?.dispose();
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    // Fill the viewfinder box (cropping the edges) instead of letterboxing.
    // previewSize is reported in landscape, so width/height swap in portrait.
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  LiveCameraException _friendly(CameraException e) {
    final code = e.code.toLowerCase();
    if (code.contains('denied') || code.contains('restricted')) {
      return LiveCameraException(
        'Camera access is turned off. Allow it in your settings, or choose from your gallery.',
        detail: e.description,
      );
    }
    return LiveCameraException(
      "Couldn't open the camera. Try choosing from your gallery instead.",
      detail: e.description,
    );
  }
}

/// Same as live_camera_stub.dart, for non-Android platforms.
class _UnavailableLiveCamera implements LiveCamera {
  static const _error = LiveCameraException(
    "The camera isn't available on this device yet. Try choosing from your gallery instead.",
  );

  @override
  Future<int> open() async => throw _error;

  @override
  Future<int> switchCamera() async => throw _error;

  @override
  Future<Uint8List> capture() async => throw _error;

  @override
  void close() {}

  @override
  Widget buildPreview() => const SizedBox.shrink();
}