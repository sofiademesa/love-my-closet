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
import 'take_photo_screen.dart';

/// What Adding Item Photo hands back to Add Clothes when User taps "Use Photo".
class ProcessedPhoto {
  const ProcessedPhoto({required this.bytes, required this.backgroundColorName});

  final Uint8List bytes;

  final String backgroundColorName;
}

/// Preview backdrops: the same colors as the Color dropdown (White default).
final List<String> _previewBackgrounds = List.unmodifiable(clothingColors);

enum _Phase { idle, picking, processing }

/// Where the photo comes from, chosen with the toggle above the photo box.
enum _PhotoMode { camera, gallery }

/// Adding Item Photo: the capture/preview step reached from the photo box
/// on Add Clothes. Lets Users take a photo or choose one from the gallery,
/// automatically removes the background, previews the transparent cutout,
/// then Undo or Use Photo. Pops a [ProcessedPhoto] on Use Photo, or null.
class AddingItemPhotoScreen extends StatefulWidget {
  const AddingItemPhotoScreen({
    super.key,
    this.initialBackground = defaultClothingColor,
    this.photoSource,
    this.backgroundRemover,
    this.takePhoto,
  });

  final String initialBackground;

  /// Overridable so tests can fake the camera/gallery and the network.
  final PhotoSourceService? photoSource;
  final BackgroundRemovalService? backgroundRemover;

  /// Opens the camera and returns the captured bytes (null if cancelled).
  /// Defaults to [TakePhotoScreen]; overridable so tests can fake it.
  final Future<Uint8List?> Function(BuildContext context)? takePhoto;

  @override
  State<AddingItemPhotoScreen> createState() => _AddingItemPhotoScreenState();
}

class _AddingItemPhotoScreenState extends State<AddingItemPhotoScreen> {
  late final PhotoSourceService _photos = widget.photoSource ?? PhotoSourceService();
  late final BackgroundRemovalService _remover =
      widget.backgroundRemover ?? createBackgroundRemover();

  _Phase _phase = _Phase.idle;
  _PhotoMode _mode = _PhotoMode.camera;
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

  Future<void> _pickFromGallery() =>
      _getPhoto(() => _photos.pick(ImageSource.gallery));

  Future<void> _takePhoto() => _getPhoto(() {
        final take = widget.takePhoto;
        if (take != null) return take(context);
        return Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(builder: (_) => const TakePhotoScreen()),
        );
      });

  /// Shared by Take Photo and Choose from Gallery: gets the photo, then
  /// removes its background.
  Future<void> _getPhoto(Future<Uint8List?> Function() source) async {
    if (_busy) return;
    setState(() {
      _phase = _Phase.picking;
      _error = null;
    });
    // Head start on the one-time model download while the picker is open.
    _remover.prepare();

    try {
      final Uint8List? picked = await source();
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = "Couldn't get that photo. Please try again.";
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
                _PhotoModeToggle(
                  selected: _mode,
                  onSelected: _busy ? null : (mode) => setState(() => _mode = mode),
                ),
                const SizedBox(height: Spacing.md),
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
                                  : (_mode == _PhotoMode.camera ? _takePhoto : _pickFromGallery),
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

/// Take Photo | Choose from Gallery switch shown above the photo box.
class _PhotoModeToggle extends StatelessWidget {
  const _PhotoModeToggle({required this.selected, required this.onSelected});

  final _PhotoMode selected;
  final ValueChanged<_PhotoMode>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.button + 4),
        border: Border.all(color: AppColors.blush, width: 1.5),
        boxShadow: AppShadows.surface,
      ),
      child: Row(
        children: [
          Expanded(child: _segment(_PhotoMode.camera, 'Take Photo')),
          const SizedBox(width: 4),
          Expanded(child: _segment(_PhotoMode.gallery, 'Choose from Gallery')),
        ],
      ),
    );
  }

  Widget _segment(_PhotoMode mode, String label) {
    final isSelected = mode == selected;
    final radius = BorderRadius.circular(AppRadius.button);
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelected == null ? null : () => onSelected!(mode),
          child: AnimatedContainer(
            duration: kMotionDuration(const Duration(milliseconds: 180)),
            height: 42,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.softPink, AppColors.buttonPink],
                    )
                  : null,
              boxShadow: isSelected ? AppShadows.glow(AppColors.buttonPink) : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.mutedBrown,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown before any photo is chosen. Tapping it uses the toggle's choice.
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