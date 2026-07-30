/// Edit Profile (docs/40 §19.2, docs/41 §29) — full-screen form at `/me/edit`.
/// Avatar/cover changes upload immediately (their own endpoints); the text/genre/
/// language fields save together via `PATCH /me`. Live validation, an unsaved-
/// changes guard, and a saved-confirmation snackbar. All state + I/O live in
/// [ProfileEditController]; this screen is presentation only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/taxonomy/taxonomy_providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_dialog.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../controllers/profile_edit_controller.dart';
import '../widgets/profile_image_fields.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _penName;
  late final TextEditingController _bio;
  late final TextEditingController _location;
  late final TextEditingController _website;

  @override
  void initState() {
    super.initState();
    final ProfileEditState initial = ref.read(profileEditControllerProvider);
    _penName = TextEditingController(text: initial.penName);
    _bio = TextEditingController(text: initial.bio);
    _location = TextEditingController(text: initial.location);
    _website = TextEditingController(text: initial.websiteUrl);
  }

  @override
  void dispose() {
    _penName.dispose();
    _bio.dispose();
    _location.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _confirmDiscard() async {
    final bool discard = await QDialog.confirm(
      context,
      title: 'Discard changes?',
      message: 'Your unsaved edits will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      destructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  Future<void> _pickLanguage() async {
    final List<LanguageRef> languages =
        ref.read(taxonomyLanguagesProvider).asData?.value ??
        const <LanguageRef>[];
    if (languages.isEmpty) return;
    final LanguageRef? picked = await QBottomSheet.show<LanguageRef>(
      context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final LanguageRef language in languages)
              ListTile(
                title: Text(
                  language.nativeName.isNotEmpty
                      ? language.nativeName
                      : language.code,
                ),
                onTap: () => Navigator.of(sheetContext).pop(language),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(profileEditControllerProvider.notifier).setLanguage(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileEditState state = ref.watch(profileEditControllerProvider);
    final ProfileEditController controller = ref.read(
      profileEditControllerProvider.notifier,
    );

    ref.listen<ProfileEditState>(profileEditControllerProvider, (
      ProfileEditState? previous,
      ProfileEditState next,
    ) {
      if (next.saved && !(previous?.saved ?? false)) {
        QSnackbar.show(context, message: 'Profile updated.');
        Navigator.of(context).maybePop();
      }
    });

    return PopScope(
      canPop: !state.dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _confirmDiscard();
      },
      child: QScaffold(
        appBar: QAppBar(
          title: 'Edit profile',
          actions: <Widget>[
            TextButton(
              onPressed: state.submitting || state.uploading
                  ? null
                  : controller.save,
              child: state.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const BannerEditField(),
            Transform.translate(
              offset: const Offset(QSpacing.s4, -48),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: AvatarEditField(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                QSpacing.s4,
                0,
                QSpacing.s4,
                QSpacing.s6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (state.formError != null) ...<Widget>[
                    _FormErrorBanner(),
                    Gap.v4,
                  ],
                  QTextField(
                    label: 'Display name',
                    controller: _penName,
                    onChanged: controller.changePenName,
                    errorText: state.penNameError,
                    maxLength: Limits.penNameMax,
                    textInputAction: TextInputAction.next,
                  ),
                  Gap.v4,
                  QTextField(
                    label: 'Bio',
                    controller: _bio,
                    onChanged: controller.changeBio,
                    maxLength: Limits.bioMax,
                    contentDirectionAuto: true,
                  ),
                  Gap.v4,
                  QTextField(
                    label: 'Location',
                    controller: _location,
                    onChanged: controller.changeLocation,
                    maxLength: Limits.locationMax,
                  ),
                  Gap.v4,
                  QTextField(
                    label: 'Website',
                    controller: _website,
                    onChanged: controller.changeWebsite,
                    errorText: state.websiteError,
                    hint: 'https://…',
                    keyboardType: TextInputType.url,
                  ),
                  Gap.v5,
                  _LanguagePicker(
                    language: state.defaultLanguage,
                    onTap: _pickLanguage,
                  ),
                  Gap.v5,
                  _GenrePicker(
                    selected: state.genres,
                    onToggle: controller.toggleGenre,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(QSpacing.s3),
      decoration: BoxDecoration(
        color: tokens.colors.dangerBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, size: 18, color: tokens.colors.dangerText),
          Gap.h2,
          Expanded(
            child: Text(
              "Couldn't save your profile. Please try again.",
              style: TextStyle(color: tokens.colors.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.language, required this.onTap});

  final LanguageRef? language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Default language', style: theme.textTheme.labelLarge),
        Gap.v2,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(QSpacing.s3),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.colors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    language == null
                        ? 'Choose a language'
                        : (language!.nativeName.isNotEmpty
                              ? language!.nativeName
                              : language!.code),
                    style: TextStyle(
                      color: language == null
                          ? tokens.colors.textMuted
                          : tokens.colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: tokens.colors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenrePicker extends ConsumerWidget {
  const _GenrePicker({required this.selected, required this.onToggle});

  final List<GenreRef> selected;
  final void Function(GenreRef) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<GenreRef>> genresAsync = ref.watch(
      taxonomyGenresProvider,
    );
    final Set<String> selectedSlugs = <String>{
      for (final GenreRef g in selected) g.slug,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Genres (up to ${Limits.maxGenresPerProfile})',
          style: theme.textTheme.labelLarge,
        ),
        Gap.v2,
        genresAsync.when(
          loading: () => const SizedBox(
            height: 32,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('Genres are unavailable right now.'),
          data: (List<GenreRef> genres) => Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final GenreRef genre in genres)
                QChip(
                  label: genre.name.isNotEmpty ? genre.name : genre.slug,
                  tone: selectedSlugs.contains(genre.slug)
                      ? QChipTone.accent
                      : QChipTone.neutral,
                  onTap: () => onToggle(genre),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
