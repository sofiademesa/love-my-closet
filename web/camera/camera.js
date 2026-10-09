// Love My Closet - Take Photo camera, page-side API.
//
// Exposes window.lmcCamera for the Dart code
// (lib/services/live_camera_web.dart):
//
//   element()      -> the <video> element the live preview plays in
//   open()         -> Promise<{ ok, error, detail, cameraCount }>
//   switchCamera() -> Promise<{ ok, error, detail, cameraCount }>
//   capture()      -> Promise<{ ok, jpeg, error, detail }>  (jpeg: Uint8Array)
//   close()        -> stops the camera (the light turns off)
//
//   error: 'insecure' | 'unsupported' | 'denied' | 'not_found' |
//          'not_readable' | 'not_started' | 'internal' when ok is false
//   detail: the browser's own error name and message (also logged).
//
// Only ONE camera is ever opened: the browser's default (back camera on a
// phone, the normal webcam on a laptop). This matters on laptops that also
// have an infrared Windows Hello camera or virtual cameras (OBS, Zoom...),
// which fail to open and used to make the whole camera fail.
// Nothing is uploaded: the photo stays in the browser.
(function () {
  "use strict";

  var video = null;
  var stream = null;
  var deviceIds = [];
  var currentDeviceId = null;
  var mirror = false;

  function log(label, err) {
    if (window.console)
      console.warn("[Love My Closet] camera " + label + ":", err);
  }

  function describe(err) {
    if (!err) return "";
    return (err.name || "Error") + (err.message ? ": " + err.message : "");
  }

  function codeFor(err) {
    var name = (err && err.name) || "";
    if (
      name === "NotAllowedError" ||
      name === "PermissionDeniedError" ||
      name === "SecurityError"
    ) {
      return "denied";
    }
    if (
      name === "NotFoundError" ||
      name === "DevicesNotFoundError" ||
      name === "OverconstrainedError"
    ) {
      return "not_found";
    }
    if (
      name === "NotReadableError" ||
      name === "TrackStartError" ||
      name === "AbortError"
    ) {
      return "not_readable";
    }
    return "internal";
  }

  function fail(label, err) {
    log(label, err);
    return {
      ok: false,
      error: codeFor(err),
      detail: describe(err),
      cameraCount: deviceIds.length,
    };
  }

  // Called by Flutter each time the preview appears: a fresh <video> every
  // time, showing the current stream if the camera is already open.
  function element() {
    video = document.createElement("video");
    video.setAttribute("playsinline", "");
    video.setAttribute("autoplay", "");
    video.muted = true;
    video.style.width = "100%";
    video.style.height = "100%";
    video.style.objectFit = "contain";
    video.style.background = "transparent";
    video.style.pointerEvents = "none";
    video.style.transform = mirror ? "scaleX(-1)" : "";
    if (stream) {
      video.srcObject = stream;
      var p = video.play();
      if (p && p.catch) p.catch(function () {});
    }
    return video;
  }

  function currentVideo() {
    return video || element();
  }

  function stopStream() {
    if (stream) {
      stream.getTracks().forEach(function (t) {
        try {
          t.stop();
        } catch (_) {}
      });
    }
    stream = null;
    if (video) video.srcObject = null;
  }

  function wait(ms) {
    return new Promise(function (r) {
      setTimeout(r, ms);
    });
  }

  // Tries each constraint set in turn. Retries once more after a short
  // pause, because some laptops report NotReadableError when a camera is
  // reopened too quickly.
  function getStream(attempts) {
    var i = 0;
    var lastErr = null;
    function next() {
      if (i >= attempts.length) return Promise.reject(lastErr);
      var c = attempts[i++];
      return navigator.mediaDevices.getUserMedia(c).catch(function (err) {
        lastErr = err;
        var code = codeFor(err);
        if (code === "denied") throw err; // retrying won't help
        log("attempt failed, trying a simpler request", err);
        return (code === "not_readable" ? wait(400) : Promise.resolve()).then(
          next,
        );
      });
    }
    return next();
  }

  function attach(newStream) {
    stopStream();
    stream = newStream;
    var v = currentVideo();
    var track = stream.getVideoTracks()[0];
    var settings = track && track.getSettings ? track.getSettings() : {};
    currentDeviceId = settings.deviceId || null;
    // Mirror the preview for selfie/laptop cameras so it feels natural.
    // The captured photo itself is never mirrored.
    mirror = settings.facingMode !== "environment";
    v.style.transform = mirror ? "scaleX(-1)" : "";
    v.srcObject = stream;
    var p = v.play();
    return (p && p.catch ? p.catch(function () {}) : Promise.resolve())
      .then(function () {
        // Device labels/ids are only listed once permission is granted.
        if (!navigator.mediaDevices.enumerateDevices) return;
        return navigator.mediaDevices
          .enumerateDevices()
          .then(function (devices) {
            deviceIds = devices
              .filter(function (d) {
                return d.kind === "videoinput" && d.deviceId;
              })
              .map(function (d) {
                return d.deviceId;
              });
          })
          .catch(function () {});
      })
      .then(function () {
        return { ok: true, cameraCount: Math.max(deviceIds.length, 1) };
      });
  }

  function checkSupport() {
    if (!window.isSecureContext) {
      return {
        ok: false,
        error: "insecure",
        detail: "Page is not HTTPS or localhost",
        cameraCount: 0,
      };
    }
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return {
        ok: false,
        error: "unsupported",
        detail: "getUserMedia is not available",
        cameraCount: 0,
      };
    }
    return null;
  }

  function open() {
    var problem = checkSupport();
    if (problem) return Promise.resolve(problem);
    stopStream();
    return getStream([
      {
        audio: false,
        video: {
          facingMode: { ideal: "environment" },
          width: { ideal: 1920 },
          height: { ideal: 1080 },
        },
      },
      { audio: false, video: { facingMode: { ideal: "environment" } } },
      { audio: false, video: true },
    ])
      .then(attach)
      .catch(function (err) {
        return fail("open failed", err);
      });
  }

  function switchCamera() {
    var problem = checkSupport();
    if (problem) return Promise.resolve(problem);
    if (deviceIds.length < 2)
      return Promise.resolve({ ok: true, cameraCount: deviceIds.length });
    var start = Math.max(deviceIds.indexOf(currentDeviceId), 0);
    var previous = currentDeviceId;
    stopStream();

    // Walk through the other cameras until one opens (skipping IR/virtual
    // cameras that refuse), then fall back to the one we had.
    var tries = [];
    for (var k = 1; k <= deviceIds.length; k++) {
      tries.push(deviceIds[(start + k) % deviceIds.length]);
    }
    var j = 0;
    function next(lastErr) {
      if (j >= tries.length) {
        if (previous) {
          return navigator.mediaDevices
            .getUserMedia({
              audio: false,
              video: { deviceId: { exact: previous } },
            })
            .then(attach)
            .catch(function (err) {
              return fail("switch failed", err || lastErr);
            });
        }
        return fail("switch failed", lastErr);
      }
      var id = tries[j++];
      return navigator.mediaDevices
        .getUserMedia({ audio: false, video: { deviceId: { exact: id } } })
        .then(attach)
        .catch(function (err) {
          log("camera " + id + " would not open", err);
          return next(err);
        });
    }
    return next(null);
  }

  function capture() {
    var v = currentVideo();
    if (!stream || !v.videoWidth || !v.videoHeight) {
      return Promise.resolve({
        ok: false,
        error: "not_started",
        detail: "Camera is not ready yet",
      });
    }
    try {
      var canvas = document.createElement("canvas");
      canvas.width = v.videoWidth;
      canvas.height = v.videoHeight;
      canvas.getContext("2d").drawImage(v, 0, 0, canvas.width, canvas.height);
      return new Promise(function (resolve) {
        canvas.toBlob(
          function (blob) {
            if (!blob) {
              resolve({
                ok: false,
                error: "internal",
                detail: "Could not encode the photo",
              });
              return;
            }
            blob.arrayBuffer().then(
              function (buf) {
                resolve({ ok: true, jpeg: new Uint8Array(buf) });
              },
              function (err) {
                resolve(fail("capture failed", err));
              },
            );
          },
          "image/jpeg",
          0.92,
        );
      });
    } catch (err) {
      return Promise.resolve(fail("capture failed", err));
    }
  }

  window.lmcCamera = {
    element: element,
    open: open,
    switchCamera: switchCamera,
    capture: capture,
    close: stopStream,
  };
})();
