// Love My Closet - on-device background removal core.
//
// Runs entirely in the user's browser: the photo is decoded, segmented by a
// small neural network (U2-Net "silueta", MIT / Apache-2.0) through
// ONNX Runtime Web (MIT), and re-encoded as a transparent PNG. Nothing about
// the photo is sent anywhere. The only network request is the one-time
// download of the model file from this same site, which is then cached.
//
// ES module. Imported by bg_worker.js (normal path) or by bg_removal.js on
// the main thread (fallback for browsers without OffscreenCanvas in workers).

import * as ort from './ort/ort.wasm.bundle.min.js';

const MODEL_SIZE = 320;
const MEAN = [0.485, 0.456, 0.406];
const STD = [0.229, 0.224, 0.225];

/** Longest side of the PNG we hand back. Keeps memory and file size sane. */
const MAX_OUTPUT_SIDE = 2048;
/** Give up on a download that makes no progress for this long. */
const DOWNLOAD_STALL_MS = 45000;
const CACHE_NAME = 'lmc-bg-removal-v1';

/** Error with a machine-readable code the Dart side maps to a message. */
export class BgError extends Error {
  constructor(code, detail) {
    super(detail ? `${code}: ${detail}` : code);
    this.code = code;
  }
}

let sessionPromise = null;

/**
 * Downloads (or loads from cache) the model and creates the ONNX session.
 * Safe to call repeatedly; concurrent callers share one download.
 */
export function prepare(baseUrl, onDownloadProgress) {
  if (!sessionPromise) {
    sessionPromise = createSession(baseUrl, onDownloadProgress).catch((e) => {
      sessionPromise = null; // allow a retry after a failure
      throw e;
    });
  }
  return sessionPromise;
}

async function createSession(baseUrl, onDownloadProgress) {
  if (typeof WebAssembly !== 'object') throw new BgError('unsupported', 'no WebAssembly');

  const report = (from, to) => (f) => {
    if (onDownloadProgress) onDownloadProgress(f < 0 ? -1 : from + (to - from) * f);
  };

  // Download (or load from cache) the runtime and the model ourselves, so a
  // missing or misplaced file gives a clear error instead of a cryptic one.
  const wasmUrl = new URL('ort/ort-wasm-simd-threaded.wasm', baseUrl).href;
  const wasmBytes = await loadAsset(wasmUrl, report(0, 0.25), isWasm, 1000000);
  const modelUrl = new URL('models/silueta.onnx', baseUrl).href;
  const modelBytes = await loadAsset(modelUrl, report(0.25, 1), isOnnx, 1000000);
  if (onDownloadProgress) onDownloadProgress(1);

  ort.env.wasm.wasmBinary = wasmBytes.buffer;
  // Multi-threading needs cross-origin isolation, which static hosts like
  // GitHub Pages cannot enable. Single-threaded SIMD works everywhere.
  ort.env.wasm.numThreads = globalThis.crossOriginIsolated ? Math.min(4, navigator.hardwareConcurrency || 1) : 1;
  try {
    return await ort.InferenceSession.create(modelBytes, {
      executionProviders: ['wasm'],
      graphOptimizationLevel: 'all',
    });
  } catch (e) {
    throw new BgError('unsupported', String(e && e.message || e));
  }
}

const isWasm = (b) => b[0] === 0x00 && b[1] === 0x61 && b[2] === 0x73 && b[3] === 0x6d;
// ONNX files are protobufs that start with the ir_version field (tag 0x08).
const isOnnx = (b) => b[0] === 0x08;

function checkAsset(url, bytes, isValid, minBytes) {
  if (bytes.byteLength < minBytes || !isValid(bytes)) {
    const looksLikeHtml = bytes[0] === 0x3c; // '<'
    throw new BgError('files_missing', `${url} ${looksLikeHtml
      ? 'returned an HTML page (file not found)'
      : `is not a valid file (${bytes.byteLength} bytes)`}`);
  }
}

async function loadAsset(url, onProgress, isValid, minBytes) {
  let cache = null;
  try {
    if (globalThis.caches) cache = await caches.open(CACHE_NAME);
  } catch (_) { cache = null; } // e.g. private mode / insecure context
  if (cache) {
    try {
      const hit = await cache.match(url);
      if (hit) {
        const buf = new Uint8Array(await hit.arrayBuffer());
        if (buf.byteLength >= minBytes && isValid(buf)) {
          if (onProgress) onProgress(1);
          return buf;
        }
      }
    } catch (_) { /* fall through to network */ }
  }

  const controller = new AbortController();
  let stallTimer = setTimeout(() => controller.abort(), DOWNLOAD_STALL_MS);
  const bump = () => {
    clearTimeout(stallTimer);
    stallTimer = setTimeout(() => controller.abort(), DOWNLOAD_STALL_MS);
  };

  try {
    const res = await fetch(url, { signal: controller.signal });
    if (res.status === 404) throw new BgError('files_missing', `${url} not found (404)`);
    if (!res.ok) throw new BgError('model_download', `${url} HTTP ${res.status}`);
    const total = Number(res.headers.get('content-length')) || 0;
    let bytes;
    if (res.body && res.body.getReader) {
      const reader = res.body.getReader();
      const chunks = [];
      let received = 0;
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
        received += value.byteLength;
        bump();
        if (onProgress) onProgress(total ? Math.min(received / total, 0.99) : -1);
      }
      bytes = new Uint8Array(received);
      let offset = 0;
      for (const c of chunks) { bytes.set(c, offset); offset += c.byteLength; }
    } else {
      bytes = new Uint8Array(await res.arrayBuffer());
    }
    checkAsset(url, bytes, isValid, minBytes);
    if (onProgress) onProgress(1);
    if (cache) {
      try {
        await cache.put(url, new Response(bytes, { headers: { 'content-type': 'application/octet-stream' } }));
      } catch (_) { /* quota full etc.: fine, just re-download next time */ }
    }
    return bytes;
  } catch (e) {
    if (e instanceof BgError) throw e;
    throw new BgError('model_download', String(e && e.message || e));
  } finally {
    clearTimeout(stallTimer);
  }
}

// ---------------------------------------------------------------------------
// Canvas helpers that work both in a worker (OffscreenCanvas) and on the page.

function makeCanvas(w, h) {
  if (typeof OffscreenCanvas !== 'undefined') return new OffscreenCanvas(w, h);
  const c = document.createElement('canvas');
  c.width = w;
  c.height = h;
  return c;
}

function ctx2d(canvas) {
  const ctx = canvas.getContext('2d', { willReadFrequently: true });
  if (!ctx) throw new BgError('unsupported', 'no 2d canvas');
  return ctx;
}

async function canvasToPng(canvas) {
  if (canvas.convertToBlob) return canvas.convertToBlob({ type: 'image/png' });
  return new Promise((resolve, reject) =>
    canvas.toBlob((b) => (b ? resolve(b) : reject(new BgError('internal', 'toBlob failed'))), 'image/png'));
}

async function decode(bytes) {
  const blob = new Blob([bytes]);
  try {
    // 'from-image' applies the EXIF rotation that phone cameras rely on.
    return await createImageBitmap(blob, { imageOrientation: 'from-image' });
  } catch (_) {
    try {
      return await createImageBitmap(blob);
    } catch (e) {
      throw new BgError('decode', String(e && e.message || e));
    }
  }
}

// ---------------------------------------------------------------------------
// Mask clean-up.

/**
 * Keeps the main item (and any other big pieces, e.g. the second shoe of a
 * pair) and drops small stray blobs the model picked up in the background.
 * Returns null when nothing big enough was found.
 */
function cleanMask(mask, size) {
  const n = size * size;
  const labels = new Int32Array(n);
  const areas = [0];
  const stack = new Int32Array(n);
  for (let i = 0; i < n; i++) {
    if (labels[i] || mask[i] < 0.5) continue;
    const label = areas.length;
    let area = 0;
    let sp = 0;
    stack[sp++] = i;
    labels[i] = label;
    while (sp) {
      const p = stack[--sp];
      area++;
      const x = p % size;
      const y = (p / size) | 0;
      if (x > 0 && !labels[p - 1] && mask[p - 1] >= 0.5) { labels[p - 1] = label; stack[sp++] = p - 1; }
      if (x < size - 1 && !labels[p + 1] && mask[p + 1] >= 0.5) { labels[p + 1] = label; stack[sp++] = p + 1; }
      if (y > 0 && !labels[p - size] && mask[p - size] >= 0.5) { labels[p - size] = label; stack[sp++] = p - size; }
      if (y < size - 1 && !labels[p + size] && mask[p + size] >= 0.5) { labels[p + size] = label; stack[sp++] = p + size; }
    }
    areas.push(area);
  }

  const largest = Math.max(0, ...areas);
  if (largest < n * 0.004) return null;

  const keepLabel = areas.map((a) => a >= largest * 0.12);
  // Pixels that belong to a kept piece, grown by a few pixels so their soft
  // (semi-transparent) edges survive.
  let keep = new Uint8Array(n);
  for (let i = 0; i < n; i++) if (labels[i] && keepLabel[labels[i]]) keep[i] = 1;
  for (let pass = 0; pass < 3; pass++) {
    const next = keep.slice();
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        const p = y * size + x;
        if (keep[p]) continue;
        if ((x > 0 && keep[p - 1]) || (x < size - 1 && keep[p + 1]) ||
            (y > 0 && keep[p - size]) || (y < size - 1 && keep[p + size])) next[p] = 1;
      }
    }
    keep = next;
  }

  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) out[i] = keep[i] ? mask[i] : 0;
  return out;
}

// ---------------------------------------------------------------------------

/**
 * Photo bytes (JPG/PNG/WebP/...) in, transparent PNG bytes out.
 * Callbacks: onStage('download'|'processing', fraction or -1).
 */
export async function removeBackground(bytes, baseUrl, onStage) {
  const bitmap = await decode(bytes);
  try {
    const session = await prepare(baseUrl, (f) => onStage && onStage('download', f));
    if (onStage) onStage('processing', -1);

    const scale = Math.min(1, MAX_OUTPUT_SIDE / Math.max(bitmap.width, bitmap.height));
    const W = Math.max(1, Math.round(bitmap.width * scale));
    const H = Math.max(1, Math.round(bitmap.height * scale));

    // 1. Model input: the photo squashed to 320x320, normalized, NCHW.
    const small = makeCanvas(MODEL_SIZE, MODEL_SIZE);
    const sctx = ctx2d(small);
    sctx.imageSmoothingQuality = 'high';
    sctx.drawImage(bitmap, 0, 0, MODEL_SIZE, MODEL_SIZE);
    const px = sctx.getImageData(0, 0, MODEL_SIZE, MODEL_SIZE).data;
    const plane = MODEL_SIZE * MODEL_SIZE;
    const input = new Float32Array(3 * plane);
    for (let i = 0; i < plane; i++) {
      input[i] = (px[i * 4] / 255 - MEAN[0]) / STD[0];
      input[plane + i] = (px[i * 4 + 1] / 255 - MEAN[1]) / STD[1];
      input[2 * plane + i] = (px[i * 4 + 2] / 255 - MEAN[2]) / STD[2];
    }

    // 2. Run the model. Output 0 is the final saliency map in [0, 1].
    const feeds = { [session.inputNames[0]]: new ort.Tensor('float32', input, [1, 3, MODEL_SIZE, MODEL_SIZE]) };
    const outName = session.outputNames[0];
    let raw;
    try {
      const result = await session.run(feeds, [outName]);
      raw = result[outName].data;
    } catch (e) {
      throw new BgError('internal', String(e && e.message || e));
    }

    let min = Infinity;
    let max = -Infinity;
    for (let i = 0; i < plane; i++) {
      if (raw[i] < min) min = raw[i];
      if (raw[i] > max) max = raw[i];
    }
    if (!(max >= 0.3)) throw new BgError('no_subject');

    // 3. Normalize, trim faint haze, drop stray blobs.
    const range = max - min || 1;
    const mask = new Float32Array(plane);
    for (let i = 0; i < plane; i++) {
      const v = (raw[i] - min) / range;
      mask[i] = v <= 0.04 ? 0 : v >= 0.96 ? 1 : (v - 0.04) / 0.92;
    }
    const cleaned = cleanMask(mask, MODEL_SIZE);
    if (!cleaned) throw new BgError('no_subject');

    // 4. Scale the mask up to the output size (smooth edges).
    const maskCanvas = makeCanvas(MODEL_SIZE, MODEL_SIZE);
    const mctx = ctx2d(maskCanvas);
    const mImg = mctx.createImageData(MODEL_SIZE, MODEL_SIZE);
    for (let i = 0; i < plane; i++) {
      mImg.data[i * 4] = 255;
      mImg.data[i * 4 + 1] = 255;
      mImg.data[i * 4 + 2] = 255;
      mImg.data[i * 4 + 3] = Math.round(cleaned[i] * 255);
    }
    mctx.putImageData(mImg, 0, 0);
    const bigMask = makeCanvas(W, H);
    const bmctx = ctx2d(bigMask);
    bmctx.imageSmoothingQuality = 'high';
    bmctx.drawImage(maskCanvas, 0, 0, W, H);
    const alpha = bmctx.getImageData(0, 0, W, H).data;

    // 5. The real photo pixels + the mask as alpha. No backdrop is painted:
    //    everything outside the item is fully transparent.
    const full = makeCanvas(W, H);
    const fctx = ctx2d(full);
    fctx.imageSmoothingQuality = 'high';
    fctx.drawImage(bitmap, 0, 0, W, H);
    const img = fctx.getImageData(0, 0, W, H);
    const d = img.data;
    let x0 = W, y0 = H, x1 = -1, y1 = -1;
    for (let y = 0; y < H; y++) {
      for (let x = 0; x < W; x++) {
        const i = (y * W + x) * 4;
        const a = Math.round((alpha[i + 3] * d[i + 3]) / 255);
        d[i + 3] = a;
        if (a === 0) {
          d[i] = 0; d[i + 1] = 0; d[i + 2] = 0;
        } else if (a > 8) {
          if (x < x0) x0 = x;
          if (x > x1) x1 = x;
          if (y < y0) y0 = y;
          if (y > y1) y1 = y;
        }
      }
    }
    if (x1 < 0) throw new BgError('no_subject');
    fctx.putImageData(img, 0, 0);

    // 6. Crop to the item with a little breathing room, encode as PNG.
    const pad = Math.round(Math.max(W, H) * 0.03);
    const cx = Math.max(0, x0 - pad);
    const cy = Math.max(0, y0 - pad);
    const cw = Math.min(W, x1 + pad + 1) - cx;
    const ch = Math.min(H, y1 + pad + 1) - cy;
    const out = makeCanvas(cw, ch);
    ctx2d(out).drawImage(full, cx, cy, cw, ch, 0, 0, cw, ch);
    const png = await canvasToPng(out);
    return new Uint8Array(await png.arrayBuffer());
  } finally {
    if (bitmap.close) bitmap.close();
  }
}
