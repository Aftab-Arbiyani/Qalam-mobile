/// A comment field whose `@` opens a typeahead over people (P-2,
/// `platfrom/docs/48` §5.1).
///
/// **Why this wraps [TextField] rather than replacing it with a rich input.** The
/// alternative — a custom editable holding real chip spans — buys nothing here and
/// costs a great deal: selection and IME handling on a surface where mixed-direction
/// Urdu/English text is a first-class case. This keeps an ordinary [TextField] and
/// moves the display↔raw translation to submit time (`mention_text.dart`), where it
/// is a pure function over the final string. The writer sees `@farheen`; the server
/// is sent `@<uuid>`; nothing in between has to track span positions.
///
/// So there is exactly one thing this widget adds to a text field: the list of
/// people, and the semantics on it.
///
/// **Where the list sits, and how it differs from web.** Web anchors an ARIA
/// `listbox` popup over the page and drives it from the textarea with
/// `aria-activedescendant`, because a desktop writer navigates it with the arrow
/// keys. Here the list is an ordinary panel *above* the field, inside the same
/// column — a touch target, chosen by tapping — and its arrival is spoken by marking
/// the panel a [Semantics.liveRegion], which is the platform's equivalent of web's
/// `aria-live`. Recorded as a deliberate per-platform difference in `docs/48` §4.1.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../mention_text.dart';
import '../providers/collaboration_providers.dart';

class MentionField extends ConsumerStatefulWidget {
  const MentionField({
    required this.storyId,
    required this.controller,
    required this.onMention,
    required this.semanticLabel,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 4,
    this.isDense = false,
    super.key,
  });

  final String storyId;
  final TextEditingController controller;

  /// Called when a person is picked, so the composer can hold the id for submit.
  final void Function(MentionCandidate candidate) onMention;

  final String semanticLabel;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool isDense;

  @override
  ConsumerState<MentionField> createState() => _MentionFieldState();
}

class _MentionFieldState extends ConsumerState<MentionField> {
  /// True once the writer has opened a mention. Gates the roster read, so a comment
  /// with no mention in it costs no requests at all.
  bool _wantsMentions = false;
  MentionTrigger? _trigger;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextOrCaretChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextOrCaretChanged);
    super.dispose();
  }

  /// Listening on the controller rather than `onChanged` is what makes the list
  /// close when the caret MOVES: tapping elsewhere in the text leaves the token
  /// without changing a character, and an `onChanged` handler never fires.
  void _onTextOrCaretChanged() {
    final TextSelection selection = widget.controller.selection;
    final MentionTrigger? next = selection.isValid && selection.isCollapsed
        ? findMentionTrigger(widget.controller.text, selection.baseOffset)
        : null;
    if (next == null && _trigger == null) return;
    setState(() {
      _trigger = next;
      if (next != null) _wantsMentions = true;
    });
  }

  void _select(MentionCandidate candidate) {
    final MentionTrigger? trigger = _trigger;
    if (trigger == null) return;
    final MentionInsertion inserted = insertMention(
      widget.controller.text,
      trigger,
      candidate,
    );
    // Setting `value` (not `text`) in one shot moves the caret with the text —
    // assigning `text` alone would collapse the caret to the end, which is wrong for
    // a mention inserted mid-sentence.
    widget.controller.value = TextEditingValue(
      text: inserted.text,
      selection: TextSelection.collapsed(offset: inserted.caret),
    );
    widget.onMention(candidate);
    setState(() => _trigger = null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MentionTrigger? trigger = _trigger;

    // Conditional on `_wantsMentions`, so the roster is fetched on the first `@`.
    final List<MentionCandidate> candidates = _wantsMentions
        ? ref.watch(mentionablePeopleProvider(widget.storyId)).asData?.value ??
              const <MentionCandidate>[]
        : const <MentionCandidate>[];

    final List<MentionCandidate> matches = trigger == null
        ? const <MentionCandidate>[]
        : filterMentionCandidates(candidates, trigger.query);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (matches.isNotEmpty) ...<Widget>[
          _MentionList(matches: matches, onSelect: _select),
          Gap.v1,
        ],
        TextField(
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          autocorrect: false,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: widget.hintText,
            isDense: widget.isDense,
            border: const OutlineInputBorder(),
            // Named on the field itself so the affordance is discoverable without a
            // writer having to guess that `@` does anything.
            helperText: 'Type @ to mention someone on this story',
            helperStyle: theme.textTheme.labelSmall,
            labelText: widget.semanticLabel,
          ),
        ),
      ],
    );
  }
}

/// The people panel. Constrained in height so a twenty-collaborator story cannot
/// push the field off screen, and scrollable inside that bound.
class _MentionList extends ConsumerWidget {
  const _MentionList({required this.matches, required this.onSelect});

  final List<MentionCandidate> matches;
  final void Function(MentionCandidate candidate) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      container: true,
      // A panel that simply appears is invisible to a screen reader; the live region
      // is what speaks it, and the count is what makes the announcement useful.
      liveRegion: true,
      label:
          'People on this story: ${matches.length} '
          '${matches.length == 1 ? 'person' : 'people'} available to mention.',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: QSpacing.s1),
            itemCount: matches.length,
            itemBuilder: (BuildContext context, int index) {
              final MentionCandidate candidate = matches[index];
              final String name = candidate.penName.trim().isNotEmpty
                  ? candidate.penName.trim()
                  : '@${candidate.username}';
              return Semantics(
                button: true,
                label: 'Mention $name, @${candidate.username}',
                child: ListTile(
                  dense: true,
                  leading: QAvatar(
                    name: name,
                    imageUrl: ref
                        .watch(mediaUrlBuilderProvider)
                        .urlForKey(candidate.avatarKey),
                    size: 28,
                  ),
                  title: Text(name, style: theme.textTheme.bodyMedium),
                  subtitle: Text(
                    '@${candidate.username}',
                    style: theme.textTheme.labelSmall,
                  ),
                  onTap: () => onSelect(candidate),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
