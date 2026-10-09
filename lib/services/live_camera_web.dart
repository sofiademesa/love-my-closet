import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'live_camera.dart';

/// window.lmcCamera, defined by web/camera/camera.js.
@JS('lmcCamera')
external _CameraApi? get _api;

extension type _CameraApi._(JSObject _) implements JSObject {
  external JSObject element();
  external JSPromise<_OpenResult> open();
  external JSPromise<_OpenResult> switchCamera();
  external JSPromise<_CaptureResult> capture();
  external void close();
}

extension type _OpenResult._(JSObject _) implements JSObject {
  external bool get ok;
  external String? get error;
  external String? get detail;
  external int? get cameraCount;
}

extension type _CaptureResult._(JSObject _) implements JSObject {
  external bool get ok;
  external JSUint8Array? get jpeg;
  external String? get error;
  external String? get detail;
}

LiveCamera createLiveCamera() => _WebLiveCamera();

const _viewType = 'lmc-camera-preview';
bool _registered = false;

class _WebLiveCamera implements LiveCamera {
  _CameraApi get _camera {
    final api = _api;
    if (api == null) {
      throw const LiveCameraException(
        "The camera didn't load. Refresh the page and try again.",
      );
    }
    return api;
  }

  @override
  Future<int> open() async => _check(await _camera.open().toDart);

  @override
  Future<int> switchCamera() async => _check(await _camera.switchCamera().toDart);

  @override
  Future<Uint8List> capture() async {
    final result = await _camera.capture().toDart;
    final jpeg = result.jpeg;
    if (!result.ok || jpeg == null) {
      throw LiveCameraException(_messageFor(result.error), detail: result.detail);
    }
    return jpeg.toDart;
  }

  @override
  void close() {
    try {
      _api?.close();
    } catch (_) {}
  }

  @override
  Widget buildPreview() {
    // If the script is missing, open() reports it; don't fail the build.
    if (_api == null) return const SizedBox.shrink();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _api!.element(),
      );
      _registered = true;
    }
    return const HtmlElementView(viewType: _viewType);
  }

  int _check(_OpenResult result) {
    if (!result.ok) {
      throw LiveCameraException(_messageFor(result.error), detail: result.detail);
    }
    return result.cameraCount ?? 1;
  }

  String _messageFor(String? code) {
    switch (code) {
      case 'denied':
        return 'Camera access is blocked. Click the camera icon in the address bar to allow it, '
            'or choose from your gallery.';
      case 'not_found':
        return 'No camera was found. Try choosing from your gallery instead.';
      case 'not_readable':
        return "Your camera couldn't start. Check that camera access is turned on in your "
            "computer's privacy settings, the camera cover is open, and no other tab or "
            'app (Zoom, Meet, Teams) is using it.';
      case 'insecure':
        return 'The camera only works on a secure (https) page. Try choosing from your gallery.';
      case 'unsupported':
        return "This browser can't use the camera. Try choosing from your gallery instead.";
      case 'not_started':
        return 'The camera is still starting. Please try again.';
      default:
        return "Couldn't use the camera. Try choosing from your gallery instead.";
    }
  }
}