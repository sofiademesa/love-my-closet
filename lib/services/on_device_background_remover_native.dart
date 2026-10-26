import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'background_removal_service.dart';
import 'image_bytes.dart';

/// Where the Android app downloads the model from, once, on first use.
/// It's the same file the web app uses (web/bg_removal/models/silueta.onnx),
/// served by the deployed site. Override with
/// `--dart-define=BG_MODEL_URL=https://...` if the site moves.
const _modelUrl = String.fromEnvironment(
  'BG_MODEL_URL',
  defaultValue: 'https://sofiademesa.github.io/love-my-closet/bg_removal/models/silueta.onnx',
);

BackgroundRemovalService createOnDeviceBackgroundRemover() =>
    Platform.isAndroid ? _NativeBackgroundRemover() : _UnavailableBackgroundRemover();

/// Platforms without an on-device remover yet (iOS, desktop, `flutter test`).
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

/// Android: the same U2-Net "silueta" model and the same steps as the web
/// version (web/bg_removal/bg_core.js), run with ONNX Runtime on the phone.
/// The photo never leaves the device; the only download is the model
/// itself, once, which is then kept in the app's files.
class _NativeBackgroundRemover extends BackgroundRemovalService {
  // One session for the whole app, shared by every remover instance.
  static Future<OrtSession>? _session;

  /// Whoever is waiting on the download right now (the download may have
  /// been started earlier by [prepare], with nobody listening).
  static void Function(double?)? _downloadListener;

  @override
  void prepare() {
    // Only a head start; removeBackground reports real problems.
    _sessionFuture().then((_) {}, onError: (Object _) {});
  }

  static Future<OrtSession> _sessionFuture() {
    return _session ??= _createSession().catchError((Object e) {
      _session = null; // allow a retry after a failure
      throw e;
    });
  }

  static Future<OrtSession> _createSession() async {
    final file = await _modelFile((f) => _downloadListener?.call(f));
    try {
      return await OnnxRuntime().createSession(file.path);
    } catch (_) {
      // A broken file: delete it so the next try downloads it again.
      try {
        await file.delete();
      } catch (_) {}
      throw const _Failure('unsupported');
    }
  }

  @override
  Future<Uint8List> removeBackground(
    Uint8List imageBytes, {
    BackgroundRemovalProgress? onProgress,
  }) async {
    try {
      _downloadListener =
          onProgress == null ? null : (f) => onProgress(BackgroundRemovalStage.preparing, f);
      final OrtSession session;
      try {
        session = await _sessionFuture();
      } finally {
        _downloadListener = null;
      }
      onProgress?.call(BackgroundRemovalStage.removing, null);

      // 1. Decode, fix rotation, shrink, and build the model input
      //    (off the UI thread so the app doesn't freeze).
      final prepared = await _prepareInBackground(imageBytes);

      // 2. Run the model.
      final input = await OrtValue.fromList(
        prepared.input,
        [1, 3, _kModelSize, _kModelSize],
      );
      final Float32List raw;
      try {
        final outName = session.outputNames.first;
        final outputs = await session.run({session.inputNames.first: input});
        try {
          final out = outputs[outName];
          if (out == null) throw const _Failure('internal');
          final flat = await out.asFlattenedList();
          raw = Float32List.fromList([
            for (var i = 0; i < _kPlane; i++) (flat[i] as num).toDouble(),
          ]);
        } finally {
          for (final v in outputs.values) {
            await v.dispose();
          }
        }
      } finally {
        await input.dispose();
      }

      // 3-6. Clean the mask, cut the photo out, crop, encode PNG.
      final png = await _finishInBackground(prepared, raw);
      if (!isPng(png)) throw const _Failure('internal');
      return png;
    } on _Failure catch (e) {
      throw BackgroundRemovalException(_messageFor(e.code));
    } on BackgroundRemovalException {
      rethrow;
    } catch (_) {
      throw BackgroundRemovalException(_messageFor('internal'));
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'model_download':
        return "Couldn't download the background remover. Check your connection and try again.";
      case 'decode':
        return "Couldn't open that photo. Try a JPG or PNG.";
      case 'no_subject':
        return "Couldn't find the clothing in that photo. Try a clearer photo on a plain background.";
      case 'unsupported':
        return "This phone couldn't start the background remover. Please try again.";
      default:
        return 'Something went wrong removing the background. Please try again.';
    }
  }
}

// Top-level on purpose: a closure made inside a method can carry that
// method's other variables (like the screen's progress callback) into the
// background isolate, which isn't allowed.
Future<_Prepared> _prepareInBackground(Uint8List bytes) => Isolate.run(() => _prepare(bytes));

Future<Uint8List> _finishInBackground(_Prepared p, Float32List raw) =>
    Isolate.run(() => _finish(p, raw));

class _Failure implements Exception {
  const _Failure(this.code);
  final String code;
}

// -----------------------------------------------------------------------------
// The model file: downloaded once into the app's own files.

const _kMinModelBytes = 1000000;
const _kStall = Duration(seconds: 45);

Future<File> _modelFile(void Function(double?)? onProgress) async {
  final dir = Directory('${(await getApplicationSupportDirectory()).path}/bg_removal');
  final file = File('${dir.path}/silueta.onnx');
  if (await _looksValid(file)) {
    onProgress?.call(1);
    return file;
  }
  await dir.create(recursive: true);
  final part = File('${file.path}.part');
  final client = HttpClient()..connectionTimeout = _kStall;
  try {
    final request = await client.getUrl(Uri.parse(_modelUrl));
    final response = await request.close().timeout(_kStall);
    if (response.statusCode != 200) throw const _Failure('model_download');
    final total = response.contentLength; // -1 when unknown
    final sink = part.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.timeout(_kStall)) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total > 0 ? math.min(received / total, 0.99) : null);
      }
    } finally {
      await sink.close();
    }
    if (!await _looksValid(part)) throw const _Failure('model_download');
    await part.rename(file.path);
    onProgress?.call(1);
    return file;
  } on _Failure {
    rethrow;
  } catch (_) {
    throw const _Failure('model_download');
  } finally {
    client.close(force: true);
    try {
      if (await part.exists()) await part.delete();
    } catch (_) {}
  }
}

/// ONNX files are protobufs that start with the ir_version field (0x08).
Future<bool> _looksValid(File f) async {
  try {
    if (!await f.exists() || await f.length() < _kMinModelBytes) return false;
    final raf = await f.open();
    try {
      final first = await raf.read(1);
      return first.isNotEmpty && first[0] == 0x08;
    } finally {
      await raf.close();
    }
  } catch (_) {
    return false;
  }
}

// -----------------------------------------------------------------------------
// Image work. Same numbers as web/bg_removal/bg_core.js.

const _kModelSize = 320;
const _kPlane = _kModelSize * _kModelSize;
const _kMean = [0.485, 0.456, 0.406];
const _kStd = [0.229, 0.224, 0.225];

/// Longest side of the PNG we hand back.
const _kMaxOutputSide = 2048;

class _Prepared {
  const _Prepared(this.input, this.rgba, this.width, this.height);

  /// Model input, NCHW, normalized.
  final Float32List input;

  /// The photo at output size, RGBA.
  final Uint8List rgba;
  final int width;
  final int height;
}

_Prepared _prepare(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const _Failure('decode');
  // Phone cameras rely on the EXIF rotation. Then plain 8-bit RGBA, whatever
  // the file was (16-bit PNG, palette PNG, grayscale, JPG without alpha).
  var photo = img
      .bakeOrientation(decoded)
      .convert(format: img.Format.uint8, numChannels: 4);

  final scale = math.min(1.0, _kMaxOutputSide / math.max(photo.width, photo.height));
  if (scale < 1) {
    photo = img.copyResize(
      photo,
      width: math.max(1, (photo.width * scale).round()),
      height: math.max(1, (photo.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
  }
  // A fresh copy (offset 0, exact length) that's safe to change later.
  final rgba = Uint8List.fromList(photo.getBytes(order: img.ChannelOrder.rgba));

  // 1. The photo squashed to 320x320, normalized, NCHW.
  final small = img.copyResize(
    photo,
    width: _kModelSize,
    height: _kModelSize,
    interpolation: img.Interpolation.average,
  );
  final px = small.getBytes(order: img.ChannelOrder.rgba);
  final input = Float32List(3 * _kPlane);
  for (var i = 0; i < _kPlane; i++) {
    input[i] = (px[i * 4] / 255 - _kMean[0]) / _kStd[0];
    input[_kPlane + i] = (px[i * 4 + 1] / 255 - _kMean[1]) / _kStd[1];
    input[2 * _kPlane + i] = (px[i * 4 + 2] / 255 - _kMean[2]) / _kStd[2];
  }
  return _Prepared(input, rgba, photo.width, photo.height);
}

Uint8List _finish(_Prepared p, Float32List raw) {
  // 2b. The model's saliency map: is anything there at all?
  var min = double.infinity;
  var max = double.negativeInfinity;
  for (var i = 0; i < _kPlane; i++) {
    if (raw[i] < min) min = raw[i];
    if (raw[i] > max) max = raw[i];
  }
  if (!(max >= 0.3)) throw const _Failure('no_subject');

  // 3. Normalize, trim faint haze, drop stray blobs.
  final range = (max - min) == 0 ? 1.0 : max - min;
  final mask = Float32List(_kPlane);
  for (var i = 0; i < _kPlane; i++) {
    final v = (raw[i] - min) / range;
    mask[i] = v <= 0.04 ? 0 : (v >= 0.96 ? 1 : (v - 0.04) / 0.92);
  }
  final cleaned = _cleanMask(mask, _kModelSize);
  if (cleaned == null) throw const _Failure('no_subject');

  // 4. Scale the mask up to the photo's size (smooth edges).
  final maskBytes = Uint8List(_kPlane);
  for (var i = 0; i < _kPlane; i++) {
    maskBytes[i] = (cleaned[i] * 255).round();
  }
  final smallMask = img.Image.fromBytes(
    width: _kModelSize,
    height: _kModelSize,
    bytes: maskBytes.buffer,
    numChannels: 1,
  );
  final bigMask = img.copyResize(
    smallMask,
    width: p.width,
    height: p.height,
    interpolation: img.Interpolation.linear,
  );
  final alpha = bigMask.getBytes(); // one byte per pixel

  // 5. The real photo pixels + the mask as alpha. Nothing is painted behind.
  final w = p.width;
  final h = p.height;
  final d = p.rgba;
  var x0 = w, y0 = h, x1 = -1, y1 = -1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final pi = y * w + x;
      final i = pi * 4;
      final a = (alpha[pi] * d[i + 3] / 255).round();
      d[i + 3] = a;
      if (a == 0) {
        d[i] = 0;
        d[i + 1] = 0;
        d[i + 2] = 0;
      } else if (a > 8) {
        if (x < x0) x0 = x;
        if (x > x1) x1 = x;
        if (y < y0) y0 = y;
        if (y > y1) y1 = y;
      }
    }
  }
  if (x1 < 0) throw const _Failure('no_subject');

  // 6. Crop to the item with a little breathing room, encode as PNG.
  final full = img.Image.fromBytes(width: w, height: h, bytes: d.buffer, numChannels: 4);
  final pad = (math.max(w, h) * 0.03).round();
  final cx = math.max(0, x0 - pad);
  final cy = math.max(0, y0 - pad);
  final cw = math.min(w, x1 + pad + 1) - cx;
  final ch = math.min(h, y1 + pad + 1) - cy;
  final cropped = img.copyCrop(full, x: cx, y: cy, width: cw, height: ch);
  return img.encodePng(cropped);
}

/// Keeps the main item (and any other big pieces, e.g. the second shoe of a
/// pair) and drops small stray blobs. Null when nothing big enough is found.
Float32List? _cleanMask(Float32List mask, int size) {
  final n = size * size;
  final labels = Int32List(n);
  final areas = <int>[0];
  final stack = Int32List(n);
  for (var i = 0; i < n; i++) {
    if (labels[i] != 0 || mask[i] < 0.5) continue;
    final label = areas.length;
    var area = 0;
    var sp = 0;
    stack[sp++] = i;
    labels[i] = label;
    while (sp > 0) {
      final p = stack[--sp];
      area++;
      final x = p % size;
      final y = p ~/ size;
      if (x > 0 && labels[p - 1] == 0 && mask[p - 1] >= 0.5) {
        labels[p - 1] = label;
        stack[sp++] = p - 1;
      }
      if (x < size - 1 && labels[p + 1] == 0 && mask[p + 1] >= 0.5) {
        labels[p + 1] = label;
        stack[sp++] = p + 1;
      }
      if (y > 0 && labels[p - size] == 0 && mask[p - size] >= 0.5) {
        labels[p - size] = label;
        stack[sp++] = p - size;
      }
      if (y < size - 1 && labels[p + size] == 0 && mask[p + size] >= 0.5) {
        labels[p + size] = label;
        stack[sp++] = p + size;
      }
    }
    areas.add(area);
  }

  final largest = areas.reduce(math.max);
  if (largest < n * 0.004) return null;

  final keepLabel = [for (final a in areas) a >= largest * 0.12];
  // Kept pieces, grown by a few pixels so their soft edges survive.
  var keep = Uint8List(n);
  for (var i = 0; i < n; i++) {
    if (labels[i] != 0 && keepLabel[labels[i]]) keep[i] = 1;
  }
  for (var pass = 0; pass < 3; pass++) {
    final next = Uint8List.fromList(keep);
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final p = y * size + x;
        if (keep[p] != 0) continue;
        if ((x > 0 && keep[p - 1] != 0) ||
            (x < size - 1 && keep[p + 1] != 0) ||
            (y > 0 && keep[p - size] != 0) ||
            (y < size - 1 && keep[p + size] != 0)) {
          next[p] = 1;
        }
      }
    }
    keep = next;
  }

  final out = Float32List(n);
  for (var i = 0; i < n; i++) {
    out[i] = keep[i] != 0 ? mask[i] : 0;
  }
  return out;
}