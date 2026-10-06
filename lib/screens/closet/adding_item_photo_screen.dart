import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../animations/app_motion.dart';
import '../../models/clothing_item.dart';
import '../../services/background_removal_service.dart';
import '../../services/photo_source_service.dart';
import '../../theme.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/clothing_color_dot.dart';
import '../../widgets/dot_pattern.dart';
import '../../widgets/mouse_drag_scroll_behavior.dart';
import '../../widgets/photo_preview_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

/// What Adding Item Photo hands back to Add Clothes when Sofia taps
/// "Use Photo".
class ProcessedPhoto {
  const ProcessedPhoto({required this.bytes, required this.backgroundColorName});

  /// Transparent PNG cutout. The preview backdrop is NOT baked into it.
  final Uint8List bytes;

  /// The backdrop she previewed it on (a color name from [clothingColors]).
  final String backgroundColorName;
}

/// Preview backdrops: the same colors as the Color dropdown (White default).
final List<String> _previewBackgrounds = List.unmodifiable(clothingColors);

enum _Phase { idle, picking, processing }

/// Adding Item Photo: the capture/preview step reached from the photo box
/// on Add Clothes. Lets Sofia take a photo or choose one from the gallery,
/// automatically removes the background, previews the transparent cutout,
/// then Undo or Use Photo. Pops a [ProcessedPhoto] on Use Photo, or null.
class AddingItemPhotoScreen extends StatefulWidget {
  const AddingItemPhotoScreen({
    super.key,
    this.initialBackground = defaultClothingColor,
    this.photoSource,
    this.backgroundRemover,
  });

  final String initialBackground;

  /// Overridable so tests can fake the camera/gallery and the network.
  final PhotoSourceService? photoSource;
  final BackgroundRemovalService? backgroundRemover;

  @override
  State<AddingItemPhotoScreen> createState() => _AddingItemPhotoScreenState();
}

class _AddingItemPhotoScreenState extends State<AddingItemPhotoScreen> {
  late final PhotoSourceService _photos = widget.photoSource ?? PhotoSourceService();
  late final BackgroundRemovalService _remover =
      widget.backgroundRemover ?? createBackgroundRemover();

  bool _fromCamera = true;
  _Phase _phase = _Phase.idle;
  String? _error;

  /// Loading message: first-time model download, then the removal itself.
  String _progressText = 'Removing the background…';

  /// Image states, oldest first: [original] or [original, cutout].
  /// Undo removes the last one.
  final List<Uint8List> _history = [];

  late String _background = _previewBackgrounds.contains(widget.initialBackground)
      ? widget.initialBackground
      : defaultClothingColor;

  bool get _busy => _phase != _Phase.idle;
  bool get _processing => _phase == _Phase.processing;
  bool get _hasImage => _history.isNotEmpty;
  bool get _isCutout => _history.length > 1;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() {
      _fromCamera = source == ImageSource.camera;
      _phase = _Phase.picking;
      _error = null;
    });
    // Head start on the one-time model download while the picker is open.
    _remover.prepare();

    try {
      final picked = await _photos.pick(source);
      if (!mounted) return;
      if (picked == null) {
        // Cancelled: nothing to report, just stay where we were.
        setState(() => _phase = _Phase.idle);
        return;
      }
      setState(() {
        _history
          ..clear()
          ..add(picked);
      });
    } on PhotoSourceException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = e.message;
      });
      return;
    }

    await _removeBackground();
  }

  /// Cuts the background out of the original photo and adds the result as
  /// the newest image state. Also used as the "try again" action.
  Future<void> _removeBackground() async {
    if (_history.isEmpty) return;
    final original = _history.first;
    setState(() {
      _phase = _Phase.processing;
      _error = null;
      _progressText = 'Removing the background…';
    });

    try {
      final cutout = await _remover.removeBackground(
        original,
        onProgress: _onProgress,
      );
      if (!mounted) return;
      setState(() {
        _history
          ..clear()
          ..addAll([original, cutout]);
        _phase = _Phase.idle;
      });
    } on BackgroundRemovalException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = 'Something went wrong removing the background. Please try again.';
      });
    }
  }

  void _onProgress(BackgroundRemovalStage stage, double? fraction) {
    if (!mounted || !_processing) return;
    final String text;
    if (stage == BackgroundRemovalStage.preparing && (fraction == null || fraction < 1)) {
      final percent = fraction == null ? '' : ' ${(fraction * 100).round()}%';
      text = 'Getting the background remover ready (first time only)…$percent';
    } else {
      text = 'Removing the background…';
    }
    if (text != _progressText) setState(() => _progressText = text);
  }

  void _undo() {
    if (_busy || _history.isEmpty) return;
    setState(() {
      _history.removeLast();
      _error = null;
    });
  }

  void _usePhoto() {
    if (!_isCutout || _busy) return;
    Navigator.of(context).pop(
      ProcessedPhoto(bytes: _history.last, backgroundColorName: _background),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final String? statusText;
    if (_error != null) {
      statusText = _error;
    } else if (_processing) {
      statusText = _progressText;
    } else if (_isCutout) {
      statusText = 'Background removed! Looks great.';
    } else if (_hasImage) {
      statusText = 'Ready to remove the background.';
    } else {
      statusText = 'Take a photo or pick one from your gallery.';
    }

    // The main button turns into "Remove Background" after an Undo (or a
    // failed attempt), so the original photo can be retried without
    // re-picking it.
    final showRetry = _hasImage && !_isCutout;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: DotPattern(
        backgroundColor: AppColors.cream,
        dotColor: AppColors.softPink.withValues(alpha: 0.16),
        spacing: 18,
        dotRadius: 1.3,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackCircleButton(onTap: () => Navigator.of(context).pop()),
                    const SizedBox(width: Spacing.sm),
                    Text('Add Clothes', style: textTheme.headlineSmall!.copyWith(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.blush, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'Take Photo',
                          active: _fromCamera,
                          onTap: _busy ? null : () => _pick(ImageSource.camera),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Choose from Gallery',
                          active: !_fromCamera,
                          onTap: _busy ? null : () => _pick(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.blush, width: 1.5),
                      boxShadow: AppShadows.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (!_hasImage)
                            _EmptyPanel(
                              onTap: _busy
                                  ? null
                                  : () => _pick(_fromCamera ? ImageSource.camera : ImageSource.gallery),
                            )
                          else
                            // Checkerboard/color is only a widget behind the
                            // image; the image bytes are never modified. The
                            // untouched original sits on plain white so it
                            // doesn't look see-through.
                            PhotoPreviewBackground(
                              colorName: _isCutout ? _background : 'White',
                              child: Padding(
                                padding: const EdgeInsets.all(Spacing.md),
                                child: Image.memory(
                                  _history.last,
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stack) => Center(
                                    child: Text(
                                      "Couldn't show this photo.",
                                      style: textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_processing) _ProcessingOverlay(message: _progressText),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Icon(
                      _error != null ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
                      size: 16,
                      color: _error != null ? AppColors.errorRed : AppColors.buttonPink,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          statusText!,
                          style: textTheme.labelSmall!.copyWith(
                            color: _error != null ? AppColors.errorRed : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isCutout) ...[
                  const SizedBox(height: Spacing.sm),
                  Text('Preview background', style: textTheme.labelSmall),
                  const SizedBox(height: Spacing.xs),
                  _BackgroundPicker(
                    selected: _background,
                    onSelected: (name) => setState(() => _background = name),
                  ),
                ],
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: (_hasImage && !_busy) ? 1 : 0.5,
                        child: SecondaryButton(
                          label: 'Undo',
                          onPressed: (_hasImage && !_busy) ? _undo : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: showRetry ? 'Remove Background' : 'Use Photo',
                        onPressed: _busy
                            ? null
                            : showRetry
                                ? _removeBackground
                                : (_isCutout ? _usePhoto : null),
                        fontSize: showRetry ? 15 : 18.7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown before any photo is chosen.
class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
                child: Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.buttonPink),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Tap to add a photo',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  color: AppColors.mutedBrown.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading state drawn over the photo while the background is removed.
class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        color: AppColors.cream.withValues(alpha: 0.78),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoadingIndicator(size: 34),
              const SizedBox(height: Spacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of preview-backdrop swatches. Selecting one only changes what sits
/// behind the cutout in the preview.
class _BackgroundPicker extends StatelessWidget {
  const _BackgroundPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 10);

    return ScrollConfiguration(
      behavior: const MouseDragScrollBehavior(),
      child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final name in _previewBackgrounds)
            Semantics(
              button: true,
              selected: name == selected,
              label: '$name background',
              child: InkWell(
                onTap: () => onSelected(name),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: kMotionDuration(const Duration(milliseconds: 150)),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: name == selected ? AppColors.buttonPink : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClothingColorDot(name: name, size: 26),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          maxLines: 1,
                          style: labelStyle.copyWith(
                            fontWeight: name == selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

/// Two-way "Take Photo / Choose from Gallery" segmented control.
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: kMotionDuration(const Duration(milliseconds: 150)),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [AppColors.softPink, AppColors.buttonPink])
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.mutedBrown,
            ),
          ),
        ),
      ),
    );
  }
}