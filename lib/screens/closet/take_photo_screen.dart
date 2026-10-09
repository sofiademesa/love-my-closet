import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../animations/app_motion.dart';
import '../../services/live_camera.dart';
import '../../services/photo_source_service.dart';
import '../../theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// Take Photo: a live camera viewfinder with a shutter button, reached from
/// Adding Item Photo. Works with a laptop webcam as well as a phone camera
/// (back camera first when there is one).
///
/// Pops the captured photo's bytes, or null if user backs out. Problems
/// (no camera, permission blocked) are shown on this screen with a way back,
/// so she can choose from her gallery instead.
class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key, this.camera});

  /// Overridable for tests.
  final LiveCamera? camera;

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  late final LiveCamera _camera = widget.camera ?? LiveCamera();

  int _cameraCount = 0;
  bool _ready = false;
  bool _busy = true; // starting, switching or capturing
  bool _capturing = false;
  LiveCameraException? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _camera.close();
    super.dispose();
  }

  Future<void> _open() => _run(() async {
        _cameraCount = await _camera.open();
        _ready = true;
      });

  Future<void> _switchCamera() => _run(() async {
        _cameraCount = await _camera.switchCamera();
        _ready = true;
      });

  /// Runs a camera step with the loading state on, turning failures into
  /// the on-screen error.
  Future<void> _run(Future<void> Function() step) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await step();
      if (!mounted) return;
      setState(() => _busy = false);
    } on LiveCameraException catch (e) {
      _fail(e);
    } catch (e) {
      _fail(LiveCameraException(
        "Couldn't use the camera. Try choosing from your gallery instead.",
        detail: '$e',
      ));
    }
  }

  void _fail(LiveCameraException e) {
    if (!mounted) return;
    setState(() {
      _ready = false;
      _busy = false;
      _capturing = false;
      _error = e;
    });
  }

  Future<void> _capture() async {
    if (!_ready || _busy) return;
    setState(() {
      _busy = true;
      _capturing = true;
    });
    try {
      final Uint8List bytes = await _camera.capture();
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _busy = false;
          _capturing = false;
        });
        return;
      }
      if (bytes.length > PhotoSourceService.maxBytes) {
        _fail(const LiveCameraException('That photo is too large (over 25 MB). Please try again.'));
        return;
      }
      _camera.close();
      Navigator.of(context).pop(bytes);
    } on LiveCameraException catch (e) {
      // A failed shot keeps the camera running; just say so.
      if (!mounted) return;
      setState(() {
        _busy = false;
        _capturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _capturing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't take the photo. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close camera',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Take Photo',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 20, color: AppColors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    color: const Color(0xFF1E1A19),
                    width: double.infinity,
                    child: error != null
                        ? _CameraError(
                            error: error,
                            onRetry: _open,
                            onBack: () => Navigator.of(context).pop(),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              // Kept in the tree while starting so the
                              // browser's <video> is attached and can play.
                              _camera.buildPreview(),
                              if (!_ready)
                                const Center(child: AppLoadingIndicator(size: 34)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 44),
                  _ShutterButton(
                    busy: _capturing,
                    onTap: _ready && !_busy ? _capture : null,
                  ),
                  _cameraCount > 1 && error == null
                      ? _RoundIconButton(
                          icon: Icons.cameraswitch_rounded,
                          tooltip: 'Switch camera',
                          onTap: _ready && !_busy ? _switchCamera : null,
                        )
                      : const SizedBox(width: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap, required this.busy});

  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Take photo',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: kMotionDuration(const Duration(milliseconds: 150)),
          opacity: enabled || busy ? 1 : 0.4,
          child: Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.softPink, AppColors.buttonPink],
                ),
              ),
              child: busy
                  ? const Center(child: AppLoadingIndicator(size: 26, color: Colors.white))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: AppColors.white, semanticLabel: tooltip),
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onRetry, required this.onBack});

  final LiveCameraException error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final detail = error.detail;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Spacing.lg),
            Icon(Icons.no_photography_rounded, size: 40, color: AppColors.softPink),
            const SizedBox(height: Spacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                error.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Colors.white),
              ),
            ),
            if (detail != null && detail.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              // The browser's own words, for troubleshooting.
              Text(
                detail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            PrimaryButton(label: 'Try Again', onPressed: onRetry, fontSize: 16),
            const SizedBox(height: Spacing.sm),
            SecondaryButton(label: 'Back', onPressed: onBack),
          ],
        ),
      ),
    );
  }
}