import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'live_camera_stub.dart'
    if (dart.library.js_interop) 'live_camera_web.dart'
    as platform;

/// The camera failed. [message] is safe to show to user; [detail] is the
/// browser's own error (shown small, to help with troubleshooting).
class LiveCameraException implements Exception {
  const LiveCameraException(this.message, {this.detail});
  final String message;
  final String? detail;

  @override
  String toString() => 'LiveCameraException: $message ${detail ?? ''}';
}

/// A live camera viewfinder for Take Photo. On the web it uses the
/// browser camera directly (web/camera/camera.js), opening only the
/// default camera.
abstract class LiveCamera {
  factory LiveCamera() => platform.createLiveCamera();

  /// Starts the camera. Returns how many cameras there are (for the
  /// switch button). Throws [LiveCameraException].
  Future<int> open();

  /// Moves to the next camera. Throws [LiveCameraException].
  Future<int> switchCamera();

  /// Takes the photo as JPEG bytes. Throws [LiveCameraException].
  Future<Uint8List> capture();

  /// Stops the camera (the camera light turns off).
  void close();

  /// The live preview.
  Widget buildPreview();
}