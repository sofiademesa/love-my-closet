import 'dart:typed_data';

import 'on_device_background_remover_stub.dart'
    if (dart.library.js_interop) 'on_device_background_remover_web.dart'
    as on_device;

/// Background removal failed. [message] is safe to show to user.
class BackgroundRemovalException implements Exception {
  const BackgroundRemovalException(this.message);
  final String message;

  @override
  String toString() => 'BackgroundRemovalException: $message';
}

/// Which part of the work is running, for the loading state.
enum BackgroundRemovalStage {
  /// First use only: downloading the free on-device model (then cached).
  preparing,

  /// Cutting the clothing out of the photo.
  removing,
}

/// [fraction] is 0..1 while it is known, otherwise null.
typedef BackgroundRemovalProgress = void Function(
  BackgroundRemovalStage stage,
  double? fraction,
);

/// Turns a photo into a transparent PNG cutout.
abstract class BackgroundRemovalService {
  /// Optional: start any one-time setup (e.g. the model download) early.
  void prepare() {}

  /// [imageBytes] is a JPG/PNG/WebP photo. Returns PNG bytes with a
  /// transparent background (no backdrop color is ever painted into it).
  /// Throws [BackgroundRemovalException] on failure.
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  });
}

/// The app's default remover: free, open-source, and fully on-device.
///
/// On web it runs U2-Net ("silueta") through ONNX Runtime Web in a Web
/// Worker (see web/bg_removal/). The photo never leaves the device, there is
/// no API key, no server, and no per-use cost. Platforms without an
/// on-device implementation yet get a remover that fails with a clear
/// message instead of silently uploading anything.
BackgroundRemovalService createBackgroundRemover() =>
    on_device.createOnDeviceBackgroundRemover();