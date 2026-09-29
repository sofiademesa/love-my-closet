import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Picking a photo failed. [message] is safe to show to Sofia.
class PhotoSourceException implements Exception {
  const PhotoSourceException(this.message);
  final String message;

  @override
  String toString() => 'PhotoSourceException: $message';
}

/// Take Photo / Choose from Gallery, returning the raw image bytes.
///
/// Returns null when Sofia cancels. Permission problems and unreadable
/// files become a [PhotoSourceException] with a friendly message. Nothing is
/// uploaded or saved: the bytes only live in memory.
class PhotoSourceService {
  PhotoSourceService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Photos bigger than this are rejected before any processing.
  static const int maxBytes = 25 * 1024 * 1024;

  Future<Uint8List?> pick(ImageSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        // Skips the extra photo-library permission on iOS; we only need
        // the pixels.
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      throw PhotoSourceException(_messageFor(e, source));
    } catch (_) {
      throw PhotoSourceException(
        source == ImageSource.camera
            ? "Couldn't open the camera. Try choosing from your gallery instead."
            : "Couldn't open your gallery. Please try again.",
      );
    }

    if (file == null) return null; // cancelled

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      throw const PhotoSourceException(
        "Couldn't read that photo. Please pick another one.",
      );
    }
    if (bytes.isEmpty) {
      throw const PhotoSourceException(
        "That photo looks empty. Please pick another one.",
      );
    }
    if (bytes.length > maxBytes) {
      throw const PhotoSourceException(
        'That photo is too large (over 25 MB). Please pick a smaller one.',
      );
    }
    return bytes;
  }

  String _messageFor(PlatformException e, ImageSource source) {
    final code = e.code.toLowerCase();
    if (code.contains('camera_access') ||
        (code.contains('denied') && source == ImageSource.camera)) {
      return 'Camera access is turned off. Allow it in your settings, or choose from your gallery.';
    }
    if (code.contains('photo_access') || code.contains('denied')) {
      return 'Photo access is turned off. Allow it in your settings to choose a photo.';
    }
    if (code.contains('no_available_camera')) {
      return 'No camera was found. Try choosing from your gallery instead.';
    }
    if (code.contains('multiple_request')) {
      return 'The photo picker is already open.';
    }
    return source == ImageSource.camera
        ? "Couldn't open the camera. Try choosing from your gallery instead."
        : "Couldn't open your gallery. Please try again.";
  }
}