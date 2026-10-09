import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'live_camera.dart';

/// Used off the web (this project currently ships as a web app).
LiveCamera createLiveCamera() => _UnavailableLiveCamera();

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