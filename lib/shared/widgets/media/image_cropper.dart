/// A lightweight, dependency-free image cropper (docs/40 §34.2, docs/41 §11.11).
/// Presents the picked image in a fixed-aspect frame the user pans and zooms
/// (a square for avatars, a wide band for covers), then rasterizes the framed
/// region to a PNG and returns it as a new [PickedImage]. The server re-encodes to
/// its exact target (512² / 1500×500 WebP), so this only needs to capture the
/// user's chosen framing — no native cropper plugin required.
///
/// Full-screen modal (an editor surface, like the piece editor) rather than a
/// bottom sheet, so the pan/zoom gestures don't fight a sheet's drag-to-dismiss.
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/media/cover_image_picker.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../buttons/q_button.dart';

class QImageCropper {
  const QImageCropper._();

  /// Show the cropper for [source] at [aspectRatio] (width / height). Returns the
  /// cropped [PickedImage], or null if the user cancelled. [targetWidth] bounds the
  /// captured resolution (the long edge) so the upload stays small.
  static Future<PickedImage?> show(
    BuildContext context, {
    required PickedImage source,
    required double aspectRatio,
    required String title,
    int targetWidth = 1024,
  }) {
    return Navigator.of(context, rootNavigator: true).push<PickedImage>(
      MaterialPageRoute<PickedImage>(
        fullscreenDialog: true,
        builder: (_) => _CropperScreen(
          source: source,
          aspectRatio: aspectRatio,
          title: title,
          targetWidth: targetWidth,
        ),
      ),
    );
  }
}

class _CropperScreen extends StatefulWidget {
  const _CropperScreen({
    required this.source,
    required this.aspectRatio,
    required this.title,
    required this.targetWidth,
  });

  final PickedImage source;
  final double aspectRatio;
  final String title;
  final int targetWidth;

  @override
  State<_CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<_CropperScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final TransformationController _transform = TransformationController();
  bool _saving = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final PickedImage cropped = await _capture();
      if (!mounted) return;
      Navigator.of(context).pop(cropped);
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<PickedImage> _capture() async {
    final RenderRepaintBoundary boundary =
        _boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final double pixelRatio = (widget.targetWidth / boundary.size.width).clamp(
      1.0,
      3.0,
    );
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    final Uint8List bytes = data!.buffer.asUint8List();
    final Directory dir = await Directory.systemTemp.createTemp('qalam_crop');
    final File file = File('${dir.path}/crop.png');
    await file.writeAsBytes(bytes);
    return PickedImage(
      path: file.path,
      name: 'crop.png',
      mimeType: 'image/png',
      sizeBytes: bytes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(QSpacing.s4),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          double width = constraints.maxWidth;
                          double height = width / widget.aspectRatio;
                          if (height > constraints.maxHeight) {
                            height = constraints.maxHeight;
                            width = height * widget.aspectRatio;
                          }
                          return Semantics(
                            label:
                                'Crop area — drag to reposition, pinch to zoom',
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: ClipRect(
                                child: SizedBox(
                                  width: width,
                                  height: height,
                                  child: InteractiveViewer(
                                    transformationController: _transform,
                                    constrained: false,
                                    minScale: 1,
                                    maxScale: 5,
                                    child: SizedBox(
                                      width: width,
                                      height: height,
                                      child: Image.file(
                                        File(widget.source.path),
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(QSpacing.s4),
              child: QButton(
                label: 'Use photo',
                size: QButtonSize.lg,
                block: true,
                loading: _saving,
                onPressed: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
