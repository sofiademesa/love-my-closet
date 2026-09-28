import 'dart:typed_data';
import 'dart:ui' as ui;

/// Small helpers for checking raw image bytes without extra packages.

const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

/// True when [bytes] start with the PNG file signature.
bool isPng(Uint8List bytes) {
  if (bytes.length < _pngSignature.length) return false;
  for (var i = 0; i < _pngSignature.length; i++) {
    if (bytes[i] != _pngSignature[i]) return false;
  }
  return true;
}

/// Returns 'image/jpeg', 'image/png' or 'image/webp' based on the file's
/// first bytes, or null for anything else. Sniffing the bytes is more
/// reliable than trusting a file name or a browser-supplied mime type.
String? sniffImageMime(Uint8List b) {
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (isPng(b)) return 'image/png';
  if (b.length >= 12 &&
      b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 && // RIFF
      b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) { // WEBP
    return 'image/webp';
  }
  return null;
}

/// True when Flutter can actually decode [bytes] into a picture. Catches
/// truncated or corrupt files that still have a valid-looking header.
Future<bool> canDecodeImage(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    return true;
  } catch (_) {
    return false;
  }
}