/// Live autocomplete suggestions (docs/40 §8.3, docs/41 §16). Grouped
/// writers / tags / genres / piece-titles, each row highlighting the matched
/// query substring. A writer opens their profile; a tag/genre/piece commits a
/// search of that scope. Best-effort: an empty result (short query, error, or
/// cancelled request) renders nothing so the field stays uncluttered.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../domain/entities/autocomplete_result.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_suggestions_controller.dart';

class SearchSuggestionsView extends ConsumerWidget {
  const SearchSuggestionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AutocompleteResult> async = ref.watch(
      autocompleteProvider,
    );
    final String query = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.debouncedQuery),
    );
    final AutocompleteResult result =
        async.asData?.value ?? const AutocompleteResult();
    if (result.isEmpty) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: <Widget>[
        if (result.writers.isNotEmpty) ...<Widget>[
          _GroupHeader(label: l10n.searchSuggestWriters),
          for (final WriterSuggestion w in result.writers)
            _SuggestionRow(
              icon: Icons.person_outline,
              text: w.label,
              query: query,
              onTap: () => context.push(Routes.userProfilePath(w.username)),
            ),
        ],
        if (result.tags.isNotEmpty) ...<Widget>[
          _GroupHeader(label: l10n.searchSuggestTags),
          for (final TagSuggestion t in result.tags)
            _SuggestionRow(
              icon: Icons.tag,
              text: t.name.isNotEmpty ? t.name : t.slug,
              query: query,
              onTap: () => _submit(
                ref,
                t.name.isNotEmpty ? t.name : t.slug,
                SearchType.tags,
              ),
            ),
        ],
        if (result.genres.isNotEmpty) ...<Widget>[
          _GroupHeader(label: l10n.searchSuggestGenres),
          for (final GenreSuggestion g in result.genres)
            _SuggestionRow(
              icon: Icons.category_outlined,
              text: g.name.isNotEmpty ? g.name : g.slug,
              query: query,
              onTap: () => _submit(
                ref,
                g.name.isNotEmpty ? g.name : g.slug,
                SearchType.genres,
              ),
            ),
        ],
        if (result.pieces.isNotEmpty) ...<Widget>[
          _GroupHeader(label: l10n.searchSuggestPieces),
          for (final PieceSuggestion p in result.pieces)
            _SuggestionRow(
              icon: Icons.article_outlined,
              text: p.title,
              query: query,
              onTap: () => _submit(ref, p.title, SearchType.pieces),
            ),
        ],
      ],
    );
  }

  void _submit(WidgetRef ref, String query, SearchType type) =>
      ref.read(searchQueryControllerProvider.notifier).submit(query, type);
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s3,
        QSpacing.s4,
        QSpacing.s1,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tokens.colors.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.icon,
    required this.text,
    required this.query,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: tokens.colors.textMuted),
      title: _highlighted(context),
      onTap: onTap,
    );
  }

  /// Bold the first case-insensitive occurrence of [query] within [text].
  Widget _highlighted(BuildContext context) {
    final TextStyle base =
        Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final TextStyle match = base.copyWith(
      fontWeight: FontWeight.w700,
      color: QTokens.of(context).colors.accent,
    );
    final Text plain = Text(
      text,
      style: base,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return plain;
    // Unicode case-mapping can change string length (e.g. 'İ' lowers to two
    // code units), so offsets found in the lowered string only apply to the
    // original when the lengths still line up — otherwise skip highlighting.
    final String lower = text.toLowerCase();
    if (lower.length != text.length) return plain;
    final int index = lower.indexOf(q);
    final int end = index + q.length;
    if (index < 0 || end > text.length) return plain;
    return Text.rich(
      TextSpan(
        style: base,
        children: <TextSpan>[
          TextSpan(text: text.substring(0, index)),
          TextSpan(text: text.substring(index, end), style: match),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
