/// Avatar + banner edit fields (docs/40 §34, docs/41 §11.11). Each orchestrates the
/// UI/platform side of an image change — choose source, pick (downscaled by the
/// platform picker), crop to the target aspect via [QImageCropper], and validate
/// type/size against the shared [Limits] — then hands the cropped file to
/// [ProfileEditController] for the actual upload (no HTTP in the widget). Upload
/// progress is read back from the controller and shown as an overlay.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/media/cover_image_picker.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/media/image_cropper.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../controllers/my_profile_controller.dart';
import '../controllers/profile_edit_controller.dart';

class AvatarEditField extends ConsumerWidget {
  const AvatarEditField({super.key});

  static const double _size = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final String? avatarKey = ref.watch(
      myProfileControllerProvider.select((v) => v.asData?.value.avatarKey),
    );
    final String name = ref.watch(
      myProfileControllerProvider.select(
        (v) => v.asData?.value.displayName ?? '',
      ),
    );
    final double? progress = ref.watch(
      profileEditControllerProvider.select((s) => s.avatarProgress),
    );
    final String? url = ref.watch(mediaUrlBuilderProvider).urlForKey(avatarKey);

    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: InkWell(
        onTap: progress != null ? null : () => _change(context, ref),
        customBorder: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            QAvatar(name: name, imageUrl: url, size: _size),
            if (progress != null)
              _CircularProgressOverlay(progress: progress, size: _size)
            else
              _EditBadge(tokens: tokens),
          ],
        ),
      ),
    );
  }

  Future<void> _change(BuildContext context, WidgetRef ref) async {
    final PickedImage? image = await _pickCropValidate(
      context,
      ref,
      aspectRatio: 1,
      targetWidth: 512,
      maxMb: Limits.avatarImageMaxMb,
      title: 'Crop photo',
    );
    if (image == null) return;
    await ref
        .read(profileEditControllerProvider.notifier)
        .uploadAvatar(image.path);
  }
}

class BannerEditField extends ConsumerWidget {
  const BannerEditField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final String? coverKey = ref.watch(
      myProfileControllerProvider.select((v) => v.asData?.value.coverKey),
    );
    final double? progress = ref.watch(
      profileEditControllerProvider.select((s) => s.coverProgress),
    );
    final String? url = ref.watch(mediaUrlBuilderProvider).urlForKey(coverKey);

    return Semantics(
      button: true,
      label: 'Change cover image',
      child: InkWell(
        onTap: progress != null ? null : () => _change(context, ref),
        child: AspectRatio(
          aspectRatio: 3,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (url == null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        tokens.colors.accentSubtle,
                        tokens.colors.bgRaised,
                      ],
                    ),
                  ),
                )
              else
                QNetworkImage(url: url),
              if (progress != null)
                _LinearProgressOverlay(progress: progress)
              else
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(QSpacing.s2),
                    child: _EditBadge(tokens: tokens),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _change(BuildContext context, WidgetRef ref) async {
    final PickedImage? image = await _pickCropValidate(
      context,
      ref,
      aspectRatio: 3,
      targetWidth: 1500,
      maxMb: Limits.coverImageMaxMb,
      title: 'Crop cover',
    );
    if (image == null) return;
    await ref
        .read(profileEditControllerProvider.notifier)
        .uploadCover(image.path);
  }
}

/// Shared pick → crop → validate flow. Returns the cropped image, or null if the
/// user cancelled or the file failed a client-side type/size check.
Future<PickedImage?> _pickCropValidate(
  BuildContext context,
  WidgetRef ref, {
  required double aspectRatio,
  required int targetWidth,
  required int maxMb,
  required String title,
}) async {
  final ImageSourceKind? source = await _chooseSource(context);
  if (source == null || !context.mounted) return null;

  final PickedImage? picked = await ref
      .read(coverImagePickerProvider)
      .pick(source);
  if (picked == null || !context.mounted) return null;

  if (!Limits.acceptedImageTypes.contains(picked.mimeType)) {
    QSnackbar.show(
      context,
      message: 'Use a JPEG, PNG, or WebP image.',
      variant: QSnackbarVariant.danger,
    );
    return null;
  }

  final PickedImage? cropped = await QImageCropper.show(
    context,
    source: picked,
    aspectRatio: aspectRatio,
    targetWidth: targetWidth,
    title: title,
  );
  if (cropped == null || !context.mounted) return null;

  if (cropped.sizeBytes > maxMb * 1024 * 1024) {
    QSnackbar.show(
      context,
      message: 'That image is over $maxMb MB.',
      variant: QSnackbarVariant.danger,
    );
    return null;
  }
  return cropped;
}

Future<ImageSourceKind?> _chooseSource(BuildContext context) {
  return QBottomSheet.show<ImageSourceKind>(
    context,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () =>
                Navigator.of(sheetContext).pop(ImageSourceKind.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(sheetContext).pop(ImageSourceKind.camera),
          ),
        ],
      ),
    ),
  );
}

class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.tokens});

  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: tokens.colors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.colors.bgCanvas, width: 2),
      ),
      child: Icon(
        Icons.photo_camera_outlined,
        size: 16,
        color: tokens.colors.accentContrast,
      ),
    );
  }
}

class _CircularProgressOverlay extends StatelessWidget {
  const _CircularProgressOverlay({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: QColorSet.scrim,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: size * 0.5,
        height: size * 0.5,
        child: CircularProgressIndicator(
          value: progress == 0 ? null : progress,
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _LinearProgressOverlay extends StatelessWidget {
  const _LinearProgressOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: QColorSet.scrim,
      child: Center(
        child: SizedBox(
          width: 160,
          child: LinearProgressIndicator(
            value: progress == 0 ? null : progress,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}
