/// The cover-image field (M4; docs/40 §34). Pick / replace / remove a cover, with
/// client-side type + size validation, a queued-vs-uploading state, and an upload
/// progress bar. Selection stores a pending local path (the sync engine uploads it
/// on the next sync — instantly online, on reconnect offline); success swaps to the
/// server key. No HTTP here — all IO goes through the picker + controller.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/media/cover_image_picker.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';
import '../providers/writing_providers.dart';

class CoverField extends ConsumerWidget {
  const CoverField({required this.routeId, super.key});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(routeId))
        .asData
        ?.value;
    if (st == null) return const SizedBox.shrink();
    final double? progress = ref.watch(coverUploadProgressProvider);

    final String? key = st.draft.coverImageKey;
    final String? pendingPath = st.draft.pendingCoverPath;
    final bool hasCover = st.draft.hasCover;

    if (!hasCover) {
      return _AddCoverButton(
        tokens: tokens,
        onTap: () => _choose(context, ref),
      );
    }

    final Widget image = pendingPath != null
        ? Image.file(File(pendingPath), fit: BoxFit.cover)
        : QNetworkImage(url: ref.watch(mediaUrlBuilderProvider).urlForKey(key));

    return Semantics(
      label: 'Cover image',
      child: ClipRRect(
        borderRadius: QRadii.cardRadius,
        child: AspectRatio(
          aspectRatio: 2,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              image,
              if (progress != null)
                _UploadingOverlay(progress: progress, tokens: tokens)
              else if (pendingPath != null)
                const Positioned(
                  left: QSpacing.s2,
                  top: QSpacing.s2,
                  child: _QueuedBadge(),
                ),
              Positioned(
                right: QSpacing.s2,
                bottom: QSpacing.s2,
                child: Row(
                  children: <Widget>[
                    _CoverAction(
                      icon: Icons.edit_outlined,
                      label: 'Replace',
                      onTap: () => _choose(context, ref),
                    ),
                    const SizedBox(width: QSpacing.s2),
                    _CoverAction(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      onTap: () => ref
                          .read(
                            currentDraftControllerProvider(routeId).notifier,
                          )
                          .removeCover(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final ImageSourceKind? source = await QBottomSheet.show<ImageSourceKind>(
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
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSourceKind.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    await _pick(context, ref, source);
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ImageSourceKind source,
  ) async {
    final PickedImage? image = await ref
        .read(coverImagePickerProvider)
        .pick(source);
    if (image == null || !context.mounted) return;

    if (!Limits.acceptedImageTypes.contains(image.mimeType)) {
      QSnackbar.show(
        context,
        message: 'Use a JPEG, PNG, or WebP image.',
        variant: QSnackbarVariant.danger,
      );
      return;
    }
    if (image.sizeBytes > Limits.coverImageMaxMb * 1024 * 1024) {
      QSnackbar.show(
        context,
        message: 'That image is over ${Limits.coverImageMaxMb} MB.',
        variant: QSnackbarVariant.danger,
      );
      return;
    }
    final CurrentDraftController notifier = ref.read(
      currentDraftControllerProvider(routeId).notifier,
    );
    notifier.setCover(image);
    await notifier.saveNow();
  }
}

class _AddCoverButton extends StatelessWidget {
  const _AddCoverButton({required this.tokens, required this.onTap});
  final QTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add cover image',
      child: InkWell(
        borderRadius: QRadii.cardRadius,
        onTap: onTap,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: tokens.colors.bgRaised,
            borderRadius: QRadii.cardRadius,
            border: Border.all(color: tokens.colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_photo_alternate_outlined,
                color: tokens.colors.textSecondary,
              ),
              const SizedBox(width: QSpacing.s2),
              Text(
                'Add cover image',
                style: TextStyle(color: tokens.colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadingOverlay extends StatelessWidget {
  const _UploadingOverlay({required this.progress, required this.tokens});
  final double progress;
  final QTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: QColorSet.scrim,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                value: progress,
                color: tokens.colors.accent,
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: QSpacing.s2),
            Text(
              'Uploading… ${(progress * 100).round()}%',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuedBadge extends StatelessWidget {
  const _QueuedBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: QRadii.controlRadius,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_upload_outlined, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Will upload when online',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverAction extends StatelessWidget {
  const _CoverAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: QRadii.controlRadius,
      child: InkWell(
        borderRadius: QRadii.controlRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
