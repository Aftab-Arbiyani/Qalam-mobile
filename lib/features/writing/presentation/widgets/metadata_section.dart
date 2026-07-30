/// The piece-details section of the editor (M4): featured quote, language
/// (required by the API), genre, tags, and visibility. Reads option lists from the
/// taxonomy providers and writes every change through [CurrentDraftController] — no
/// business logic here.
library;

// Hide Material's Visibility widget — this file uses the domain `Visibility` enum.
import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/taxonomy/taxonomy_providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../domain/entities/draft.dart';
import '../controllers/current_draft_controller.dart';
import '../controllers/editor_state.dart';

class MetadataSection extends ConsumerStatefulWidget {
  const MetadataSection({required this.routeId, super.key});

  final String routeId;

  @override
  ConsumerState<MetadataSection> createState() => _MetadataSectionState();
}

class _MetadataSectionState extends ConsumerState<MetadataSection> {
  final TextEditingController _quote = TextEditingController();
  final TextEditingController _tagInput = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _quote.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  CurrentDraftController get _notifier =>
      ref.read(currentDraftControllerProvider(widget.routeId).notifier);

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final EditorState? st = ref
        .watch(currentDraftControllerProvider(widget.routeId))
        .asData
        ?.value;
    if (st == null) return const SizedBox.shrink();
    final Draft draft = st.draft;
    if (!_seeded) {
      _quote.text = draft.featuredQuote;
      _seeded = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Piece details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: tokens.colors.textPrimary),
        ),
        Gap.v4,
        QTextField(
          label: 'Featured quote',
          hint: 'A line that captures the piece (optional)',
          controller: _quote,
          contentDirectionAuto: true,
          maxLength: Limits.featuredQuoteMax,
          onChanged: _notifier.setFeaturedQuote,
        ),
        Gap.v4,
        _PickerRow(
          label: 'Language',
          value: draft.languageName.isNotEmpty ? draft.languageName : null,
          placeholder: 'Choose a language',
          required: true,
          onTap: () => _pickLanguage(context),
        ),
        Gap.v3,
        _PickerRow(
          label: 'Genre',
          value: draft.genreName,
          placeholder: 'Choose a genre',
          onTap: () => _pickGenre(context),
        ),
        Gap.v4,
        _TagsField(
          tags: draft.tags,
          controller: _tagInput,
          onAdd: (String tag) {
            final bool added = _notifier.addTag(tag);
            if (added) _tagInput.clear();
          },
          onRemove: _notifier.removeTag,
        ),
        Gap.v4,
        _VisibilityField(
          value: draft.visibility,
          onChanged: _notifier.setVisibility,
        ),
      ],
    );
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final AsyncValue<List<LanguageRef>> languages = ref.read(
      taxonomyLanguagesProvider,
    );
    final LanguageRef? picked = await _showOptions<LanguageRef>(
      context,
      title: 'Language',
      options: languages,
      labelOf: (LanguageRef l) =>
          l.nativeName.isNotEmpty ? l.nativeName : l.code,
    );
    if (picked != null) _notifier.setLanguage(picked);
  }

  Future<void> _pickGenre(BuildContext context) async {
    final AsyncValue<List<GenreRef>> genres = ref.read(taxonomyGenresProvider);
    final GenreRef? picked = await _showOptions<GenreRef>(
      context,
      title: 'Genre',
      options: genres,
      labelOf: (GenreRef g) => g.name.isNotEmpty ? g.name : g.slug,
    );
    if (picked != null) _notifier.setGenre(picked);
  }

  Future<T?> _showOptions<T>(
    BuildContext context, {
    required String title,
    required AsyncValue<List<T>> options,
    required String Function(T) labelOf,
  }) {
    return QBottomSheet.show<T>(
      context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: options.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(QSpacing.s6),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object _, StackTrace _) => Padding(
            padding: const EdgeInsets.all(QSpacing.s6),
            child: Text('Couldn’t load $title options — try again online.'),
          ),
          data: (List<T> items) => ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(QSpacing.s4),
                child: Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (final T item in items)
                ListTile(
                  title: Text(labelOf(item)),
                  onTap: () => Navigator.of(sheetContext).pop(item),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.required = false,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    final bool empty = value == null || value!.isEmpty;
    return Semantics(
      button: true,
      label: '$label: ${empty ? placeholder : value}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
          child: Row(
            children: <Widget>[
              Text(
                required ? '$label *' : label,
                style: TextStyle(
                  color: tokens.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                empty ? placeholder : value!,
                style: TextStyle(
                  color: empty
                      ? tokens.colors.textMuted
                      : tokens.colors.textPrimary,
                ),
              ),
              const SizedBox(width: QSpacing.s1),
              Icon(Icons.chevron_right, color: tokens.colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagsField extends StatelessWidget {
  const _TagsField({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final bool atLimit = tags.length >= Limits.tagsMaxPerPiece;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: QSpacing.s2),
            child: Wrap(
              spacing: QSpacing.s2,
              runSpacing: QSpacing.s2,
              children: <Widget>[
                for (final String tag in tags)
                  QChip(
                    label: '#$tag',
                    tone: QChipTone.accent,
                    onRemove: () => onRemove(tag),
                  ),
              ],
            ),
          ),
        QTextField(
          label: 'Tags (up to ${Limits.tagsMaxPerPiece})',
          hint: atLimit ? 'Tag limit reached' : 'Add a tag and press enter',
          controller: controller,
          enabled: !atLimit,
          textInputAction: TextInputAction.done,
          onSubmitted: (String value) {
            if (value.trim().isNotEmpty) onAdd(value);
          },
        ),
      ],
    );
  }
}

class _VisibilityField extends StatelessWidget {
  const _VisibilityField({required this.value, required this.onChanged});

  final Visibility value;
  final ValueChanged<Visibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Who can see this',
          style: TextStyle(
            color: tokens.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.v2,
        Wrap(
          spacing: QSpacing.s2,
          children: <Widget>[
            for (final Visibility v in Visibility.values)
              ChoiceChip(
                label: Text(_label(v)),
                selected: value == v,
                onSelected: (_) => onChanged(v),
              ),
          ],
        ),
      ],
    );
  }

  String _label(Visibility v) => switch (v) {
    Visibility.public => 'Public',
    Visibility.unlisted => 'Unlisted',
    Visibility.private => 'Private',
  };
}
