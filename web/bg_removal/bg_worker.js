// Love My Closet - background-removal worker (ES module worker).
// Runs the heavy work off the page's main thread so the app stays smooth.

import { removeBackground, prepare, BgError } from './bg_core.js';

const baseUrl = new URL('./', import.meta.url).href;

function progress(id, stage, fraction) {
  self.postMessage({ type: 'progress', id, stage, fraction });
}

self.onmessage = async (event) => {
  const msg = event.data || {};

  if (msg.type === 'check') {
    let ok = false;
    try {
      ok = typeof OffscreenCanvas !== 'undefined' &&
        typeof createImageBitmap === 'function' &&
        !!new OffscreenCanvas(1, 1).getContext('2d');
    } catch (_) {
      ok = false;
    }
    self.postMessage({ type: 'check', ok });
    return;
  }

  if (msg.type === 'prepare') {
    prepare(baseUrl, (f) => progress(null, 'download', f)).catch(() => {});
    return;
  }

  if (msg.type === 'remove') {
    const { id } = msg;
    try {
      const png = await removeBackground(new Uint8Array(msg.bytes), baseUrl,
        (stage, f) => progress(id, stage, f));
      self.postMessage({ type: 'done', id, ok: true, png: png.buffer }, [png.buffer]);
    } catch (e) {
      const code = e instanceof BgError ? e.code : 'internal';
      self.postMessage({ type: 'done', id, ok: false, error: code, detail: String(e && e.message || e) });
    }
  }
};
