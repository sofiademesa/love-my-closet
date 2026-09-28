# Third-party components in `web/bg_removal/`

Background removal runs fully in the browser. No API key, no server, no
uploads. These open-source files are served from this site itself.

## ONNX Runtime Web 1.30.0 (`ort/`)

Source: https://www.npmjs.com/package/onnxruntime-web
(`dist/ort.wasm.bundle.min.mjs`, renamed to `.js`, and
`dist/ort-wasm-simd-threaded.wasm`, both unmodified).

MIT License

Copyright (c) Microsoft Corporation.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## `models/silueta.onnx`

A size-reduced U2-Net salient-object model published by the rembg project.
Source: https://github.com/danielgatis/rembg/releases/download/v0.0.0/silueta.onnx
(unmodified, SHA-256
`75da6c8d2f8096ec743d071951be73b4a8bc7b3e51d9a6625d63644f90ffeedb`).

- rembg: MIT License, Copyright (c) 2020 Daniel Gatis.
- U2-Net architecture and original weights: Apache License 2.0,
  Copyright (c) Xuebin Qin et al. https://github.com/xuebinqin/U-2-Net
