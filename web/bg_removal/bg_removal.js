// Love My Closet - on-device background removal, page-side API.
//
// Exposes window.lmcBackgroundRemoval for the Dart code
// (lib/services/on_device_background_remover_web.dart):
//
//   remove(Uint8Array photo, onProgress?) -> Promise<{ ok, png, error }>
//     ok:    true when png holds a transparent PNG (Uint8Array)
//     error: 'unsupported' | 'files_missing' | 'model_download' | 'decode' |
//            'no_subject' | 'timeout' | 'internal' when ok is false
//     detail: technical detail (also logged to the browser console)
//     onProgress(stage, fraction): stage is 'download' (first-time model
//     download, fraction 0..1 or -1 if unknown) or 'processing'.
//   prepare() -> starts the one-time model download early (optional).
//
// No API key, no server, no upload: the photo never leaves the browser.
(function () {
  'use strict';

  var script = document.currentScript;
  var baseUrl = new URL('./', script && script.src ? script.src : new URL('bg_removal/', document.baseURI)).href;

  var PROCESSING_TIMEOUT_MS = 120000;

  var workerPromise = null;
  var nextId = 1;
  var pending = new Map(); // id -> { resolve, report, timer }
  var corePromise = null;

  function supported() {
    return typeof WebAssembly === 'object' && typeof Promise === 'function' &&
      typeof Blob === 'function' && typeof URL === 'function';
  }

  function logFailure(result) {
    if (result && !result.ok && window.console) {
      console.warn('[Love My Closet] background removal failed:', result.error, result.detail || '');
    }
    return result;
  }

  function finish(id, result) {
    var job = pending.get(id);
    if (!job) return;
    pending.delete(id);
    if (job.timer) clearTimeout(job.timer);
    job.resolve(logFailure(result));
  }

  function failAll(code) {
    Array.from(pending.keys()).forEach(function (id) {
      finish(id, { ok: false, png: null, error: code });
    });
  }

  function resetWorker(worker) {
    try { worker.terminate(); } catch (_) {}
    workerPromise = null;
  }

  function onWorkerMessage(worker, e) {
    var m = e.data || {};
    if (m.type === 'progress') {
      var targets = m.id == null ? Array.from(pending.keys()) : [m.id];
      targets.forEach(function (id) {
        var job = pending.get(id);
        if (!job) return;
        if (m.stage === 'processing' && !job.timer) {
          job.timer = setTimeout(function () {
            // A stuck job blocks the worker; start over with a fresh one.
            resetWorker(worker);
            failAll('timeout');
          }, PROCESSING_TIMEOUT_MS);
        }
        job.report(m.stage, m.fraction);
      });
    } else if (m.type === 'done') {
      finish(m.id, m.ok
        ? { ok: true, png: new Uint8Array(m.png), error: null }
        : { ok: false, png: null, error: m.error || 'internal', detail: m.detail || null });
    }
  }

  /** Resolves to a ready worker, or null when this browser can't run one. */
  function getWorker() {
    if (workerPromise) return workerPromise;
    workerPromise = new Promise(function (resolve) {
      var worker;
      try {
        worker = new Worker(new URL('bg_worker.js', baseUrl), { type: 'module' });
      } catch (_) {
        resolve(null);
        return;
      }
      var settled = false;
      var giveUp = setTimeout(function () { done(false); }, 20000);
      function done(ok) {
        if (settled) return;
        settled = true;
        clearTimeout(giveUp);
        if (!ok) {
          try { worker.terminate(); } catch (_) {}
          resolve(null);
          return;
        }
        worker.onmessage = function (e) { onWorkerMessage(worker, e); };
        worker.onerror = function () { resetWorker(worker); failAll('internal'); };
        resolve(worker);
      }
      // Fires if module workers aren't supported or the script fails to load.
      worker.onerror = function () { done(false); };
      worker.onmessage = function (e) {
        if (e.data && e.data.type === 'check') done(!!e.data.ok);
      };
      worker.postMessage({ type: 'check' });
    });
    return workerPromise;
  }

  /** Fallback for older browsers: same code on the page's main thread. */
  function getCore() {
    if (!corePromise) {
      corePromise = import(new URL('bg_core.js', baseUrl).href).catch(function (e) {
        corePromise = null;
        throw e;
      });
    }
    return corePromise;
  }

  function runInWorker(worker, bytes, report) {
    return new Promise(function (resolve) {
      var id = nextId++;
      pending.set(id, { resolve: resolve, report: report, timer: null });
      worker.postMessage({ type: 'remove', id: id, bytes: bytes.buffer }, [bytes.buffer]);
    });
  }

  function runOnMainThread(bytes, report) {
    return getCore().then(function (core) {
      return core.removeBackground(bytes, baseUrl, report).then(
        function (png) { return { ok: true, png: png, error: null }; },
        function (e) {
          return logFailure({ ok: false, png: null, error: (e && e.code) || 'internal', detail: String(e && e.message || e) });
        });
    }, function (e) {
      // bg_core.js or the ONNX Runtime script couldn't be loaded.
      return logFailure({ ok: false, png: null, error: 'files_missing',
        detail: 'could not load ' + new URL('bg_core.js', baseUrl).href + ' (' + String(e && e.message || e) + ')' });
    });
  }

  function remove(photo, onProgress) {
    var report = function (stage, fraction) {
      if (typeof onProgress !== 'function') return;
      try { onProgress(String(stage), typeof fraction === 'number' ? fraction : -1); } catch (_) {}
    };
    if (!supported()) return Promise.resolve({ ok: false, png: null, error: 'unsupported' });
    if (!(photo instanceof Uint8Array) || photo.byteLength === 0) {
      return Promise.resolve({ ok: false, png: null, error: 'decode' });
    }
    // Copy so transferring to the worker never detaches the caller's buffer.
    var bytes = photo.slice();
    return getWorker().then(function (worker) {
      return worker ? runInWorker(worker, bytes, report) : runOnMainThread(bytes, report);
    }).catch(function () {
      return { ok: false, png: null, error: 'internal' };
    });
  }

  function prepare() {
    if (!supported()) return;
    getWorker().then(function (worker) {
      if (worker) {
        worker.postMessage({ type: 'prepare' });
      } else {
        getCore().then(function (core) { return core.prepare(baseUrl); }).catch(function () {});
      }
    }).catch(function () {});
  }

  window.lmcBackgroundRemoval = { remove: remove, prepare: prepare, isSupported: supported };
})();
