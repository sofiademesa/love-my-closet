import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'background_removal_service.dart';
import 'image_bytes.dart';

/// window.lmcBackgroundRemoval, defined by web/bg_removal/bg_removal.js.
@JS('lmcBackgroundRemoval')
external _BgRemovalApi? get _api;

extension type _BgRemovalApi._(JSObject _) implements JSObject {
  external JSPromise<_BgRemovalResult> remove(
    JSUint8Array photo,
    JSFunction? onProgress,
  );
  external void prepare();
}

extension type _BgRemovalResult._(JSObject _) implements JSObject {
  external bool get ok;
  external JSUint8Array? get png;
  external String? get error;
}

BackgroundRemovalService createOnDeviceBackgroundRemover() =>
    _WebOnDeviceBackgroundRemover();

/// Runs the free, open-source U2-Net model in the browser (ONNX Runtime Web
/// in a Web Worker). No network call carries the photo; the only download
/// is the model itself, once, from this same site.
class _WebOnDeviceBackgroundRemover extends BackgroundRemovalService {
  @override
  void prepare() {
    try {
      _api?.prepare();
    } catch (_) {
      // Only a head start; removeBackground reports real problems.
    }
  }

  @override
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  }) async {
    final api = _api;
    if (api == null) {
      throw const BackgroundRemovalException(
        "The background remover didn't load. Refresh the page and try again.",
      );
    }

    JSFunction? callback;
    if (onProgress != null) {
      callback = ((JSString stage, JSNumber fraction) {
        final f = fraction.toDartDouble;
        onProgress(
          stage.toDart == 'download'
              ? BackgroundRemovalStage.preparing
              : BackgroundRemovalStage.removing,
          f < 0 ? null : f.clamp(0.0, 1.0),
        );
      }).toJS;
    }

    final _BgRemovalResult result;
    try {
      result = await api.remove(imageBytes.toJS, callback).toDart;
    } catch (_) {
      throw const BackgroundRemovalException(
        'Something went wrong removing the background. Please try again.',
      );
    }

    final png = result.png?.toDart;
    if (!result.ok || png == null) {
      throw BackgroundRemovalException(_messageFor(result.error));
    }
    if (!isPng(png) || !await canDecodeImage(png)) {
      throw const BackgroundRemovalException(
        'Something went wrong removing the background. Please try again.',
      );
    }
    return png;
  }

  String _messageFor(String? code) {
    switch (code) {
      case 'files_missing':
        return "The background remover's files didn't load. Please refresh the page and try again.";
      case 'model_download':
        return "Couldn't download the background remover. Check your connection and try again.";
      case 'decode':
        return "Couldn't open that photo. Try a JPG or PNG.";
      case 'no_subject':
        return "Couldn't find the clothing in that photo. Try a clearer photo on a plain background.";
      case 'timeout':
        return 'That took too long. Please try again.';
      case 'unsupported':
        return "This browser can't remove backgrounds. Try the latest Chrome, Safari, Edge, or Firefox.";
      default:
        return 'Something went wrong removing the background. Please try again.';
    }
  }
}