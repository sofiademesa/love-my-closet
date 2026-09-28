import 'dart:typed_data';

import 'background_removal_service.dart';

/// Used on platforms without an on-device remover yet (this project
/// currently ships as a web app, see web/bg_removal/).
BackgroundRemovalService createOnDeviceBackgroundRemover() =>
    _UnavailableBackgroundRemover();

class _UnavailableBackgroundRemover extends BackgroundRemovalService {
  @override
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  }) async {
    throw const BackgroundRemovalException(
      "Background removal isn't available on this device yet.",
    );
  }
}