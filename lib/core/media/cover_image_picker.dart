/// Cover-image selection (docs/40 §34.2). A thin, injectable boundary over the
/// platform image picker so the editor can pick + client-side downscale a cover
/// without the presentation layer touching a plugin — and so widget/provider tests
/// substitute a fake (no platform channels).
///
/// The picker DOWNSCALES and re-encodes at pick time (`maxWidth/maxHeight` +
/// `imageQuality`), which is the client-side compression the brief asks for; the
/// server also re-encodes to WebP and strips EXIF, so this only bounds bandwidth
/// and keeps the file under the 10 MB cover cap.
library;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Where to source a cover image from.
enum ImageSourceKind { gallery, camera }

/// A picked (and downscaled) image plus the metadata needed to validate + upload.
@immutable
class PickedImage {
  const PickedImage({
    required this.path,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final String mimeType;
  final int sizeBytes;
}

abstract interface class CoverImagePicker {
  /// Pick a cover image, returning null if the user cancelled.
  Future<PickedImage?> pick(ImageSourceKind source);
}

/// The real picker. Caps the long edge at ~2000px and re-encodes at 85% quality —
/// well within the cover's server-side 1500×500 target while cutting upload size.
class PlatformCoverImagePicker implements CoverImagePicker {
  PlatformCoverImagePicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double _maxEdge = 2000;
  static const int _quality = 85;

  @override
  Future<PickedImage?> pick(ImageSourceKind source) async {
    final XFile? file = await _picker.pickImage(
      source: source == ImageSourceKind.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: _maxEdge,
      maxHeight: _maxEdge,
      imageQuality: _quality,
    );
    if (file == null) return null;
    final int length = await file.length();
    return PickedImage(
      path: file.path,
      name: file.name,
      mimeType: _resolveMime(file),
      sizeBytes: length,
    );
  }

  String _resolveMime(XFile file) {
    final String? declared = file.mimeType;
    if (declared != null && declared.isNotEmpty) return declared;
    final String lower = file.name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
