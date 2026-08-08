/// Semantic Search (AF4) — a QSearchField over the reusable Retrieval Platform. Landing
/// shows recent + saved searches; typing shows suggestions; submitting shows ranked,
/// grounded, explainable results (optionally a synthesised answer). Save a search;
/// tap a result to navigate to the linked entity. The client renders; the backend ranks.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/inputs/q_search_field.dart';
import '../../../../shared/widgets/inputs/q_text_field.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/retrieval.dart';
import '../controllers/ai_search_history_controller.dart';
import '../controllers/saved_searches_controller.dart';
import '../controllers/semantic_search_controller.dart';
import '../providers/ai_providers.dart';
import '../widgets/ai_markdown.dart' show AiMarkdown;
import '../widgets/retrieval_cards.dart';
import '../widgets/retrieval_navigation.dart';
import '../widgets/search_result_sheet.dart';

class SemanticSearchScreen extends ConsumerStatefulWidget {
  const SemanticSearchScreen({super.key});

  @override
  ConsumerState<SemanticSearchScreen> createState() =>
      _SemanticSearchScreenState();
}

class _SemanticSearchScreenState extends ConsumerState<SemanticSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  String _prefix = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedSearchesControllerProvider.notifier).syncFromServer();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(retrievalSessionControllerProvider.notifier).onQueryChanged(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _prefix = value.trim());
    });
  }

  void _submit([String? query]) {
    final String q = query ?? _controller.text;
    if (query != null && _controller.text != query) _controller.text = query;
    if (ref.read(retrievalSessionControllerProvider.notifier).submit(q)) {
      _focus.unfocus();
      setState(() => _prefix = '');
    }
  }

  void _runQuery(String query) {
    _controller.text = query;
    _submit(query);
  }

  Future<void> _saveCurrent(RetrievalSession session) async {
    final String? name = await _promptName(context, session.query.trim());
    if (name == null || name.isEmpty) return;
    final result = await ref
        .read(savedSearchesControllerProvider.notifier)
        .save(
          name: name,
          query: session.query.trim(),
          storyId: session.storyId,
        );
    if (!mounted) return;
    final bool ok = result is Ok;
    QSnackbar.show(
      context,
      message: ok ? 'Search saved' : 'Could not save search',
      variant: ok ? QSnackbarVariant.success : QSnackbarVariant.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final RetrievalSession session = ref.watch(
      retrievalSessionControllerProvider,
    );
    final bool showResults = session.submitted && session.canSubmit;

    /// **B5 (`platfrom/docs/45` §4.10).** This screen carried NO runtime gate at all — it
    /// was reachable only from the AI Discovery hub, which was itself gated on the
    /// compile-time flag, so nothing here consulted the server. A writer who turned AI off
    /// would still get a live search box that 403s on the first keystroke. The account's
    /// switch is the outer gate now; per-feature flags still belong to the requests below.
    ///
    /// An unresolved read is treated as ON, so the search box never flickers off and back.
    final AiFeatures? aiFeatures = ref.watch(aiFeaturesProvider).asData?.value;
    final bool aiOn = aiFeatures?.aiEnabled ?? true;

    return QScaffold(
      appBar: QAppBar(
        title: 'AI Search',
        actions: <Widget>[
          if (showResults && aiOn)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Save this search',
              onPressed: () => _saveCurrent(session),
            ),
        ],
      ),
      body: !aiOn
          ? const QEmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'You turned AI off',
              message:
                  'AI search is off for your account. Turn AI back on in '
                  'Settings \u203A AI.',
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(QSpacing.s4),
                  child: QSearchField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    hint: 'Ask or search across your stories…',
                    onChanged: _onChanged,
                    onSubmitted: (_) => _submit(),
                    onClear: () {
                      ref
                          .read(retrievalSessionControllerProvider.notifier)
                          .onQueryChanged('');
                      setState(() => _prefix = '');
                    },
                  ),
                ),
                Expanded(
                  child: showResults
                      ? _ResultsView(
                          session: session,
                          onToggleSynthesize: () => ref
                              .read(retrievalSessionControllerProvider.notifier)
                              .toggleSynthesize(),
                        )
                      : _prefix.length >= 2
                      ? _SuggestionsView(
                          prefix: _prefix,
                          storyId: session.storyId,
                          onPick: _runQuery,
                        )
                      : _LandingView(onRun: _runQuery),
                ),
              ],
            ),
    );
  }
}

// ── Landing: recent + saved searches ──────────────────────────────────────────

class _LandingView extends ConsumerWidget {
  const _LandingView({required this.onRun});

  final void Function(String query) onRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> history = ref.watch(aiSearchHistoryControllerProvider);
    final saved = ref.watch(savedSearchesControllerProvider);

    if (history.isEmpty && saved.isEmpty) {
      return const QEmptyState(
        icon: Icons.search,
        title: 'Search your stories',
        message:
            'Find characters, scenes, places, and themes — grounded in your story graph.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
      children: <Widget>[
        if (history.isNotEmpty) ...<Widget>[
          _SectionHeader(
            title: 'Recent',
            onClear: () =>
                ref.read(aiSearchHistoryControllerProvider.notifier).clear(),
          ),
          Wrap(
            spacing: QSpacing.s2,
            runSpacing: QSpacing.s2,
            children: <Widget>[
              for (final String q in history)
                QChip(
                  label: q,
                  icon: Icons.history,
                  onTap: () => onRun(q),
                  onRemove: () => ref
                      .read(aiSearchHistoryControllerProvider.notifier)
                      .remove(q),
                ),
            ],
          ),
          Gap.v5,
        ],
        if (saved.isNotEmpty) ...<Widget>[
          Text('Saved', style: text.titleMedium),
          Gap.v2,
          for (final s in saved)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bookmark_outline),
              title: Text(s.name),
              subtitle: Text(
                s.query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
                onPressed: () => ref
                    .read(savedSearchesControllerProvider.notifier)
                    .remove(s),
              ),
              onTap: () => onRun(s.query),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onClear});

  final String title;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title, style: text.titleMedium),
        if (onClear != null)
          TextButton(onPressed: onClear, child: const Text('Clear')),
      ],
    );
  }
}

// ── Suggestions ────────────────────────────────────────────────────────────────

class _SuggestionsView extends ConsumerWidget {
  const _SuggestionsView({
    required this.prefix,
    required this.storyId,
    required this.onPick,
  });

  final String prefix;
  final String? storyId;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<String>> async = ref.watch(
      searchSuggestionsProvider((prefix: prefix, storyId: storyId)),
    );
    final List<String> suggestions = async.asData?.value ?? const <String>[];
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return ListView(
      children: <Widget>[
        for (final String s in suggestions)
          ListTile(
            leading: const Icon(Icons.north_east, size: 18),
            title: Text(s),
            onTap: () => onPick(s),
          ),
      ],
    );
  }
}

// ── Results ─────────────────────────────────────────────────────────────────────

class _ResultsView extends ConsumerWidget {
  const _ResultsView({required this.session, required this.onToggleSynthesize});

  final RetrievalSession session;
  final VoidCallback onToggleSynthesize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QColorSet colors = QTokens.of(context).colors;
    final AsyncValue<SemanticSearchResponse> async = ref.watch(
      semanticSearchResultsProvider(session.args),
    );

    return async.when(
      skipLoadingOnRefresh: true,
      loading: () => const FeedSkeletonList(),
      error: (Object e, _) => QErrorView(
        failure: e is Failure
            ? e
            : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$e'),
        onRetry: () =>
            ref.invalidate(semanticSearchResultsProvider(session.args)),
      ),
      data: (SemanticSearchResponse response) {
        if (response.results.isEmpty && (response.answer ?? '').isEmpty) {
          return const QEmptyState(
            icon: Icons.search_off,
            title: 'Nothing found',
            message: 'Try a different phrasing or a broader query.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            0,
            QSpacing.s4,
            QSpacing.s6,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                QChip(
                  label: 'AI answer',
                  icon: Icons.auto_awesome,
                  tone: session.synthesize
                      ? QChipTone.accent
                      : QChipTone.neutral,
                  onTap: onToggleSynthesize,
                ),
              ],
            ),
            if ((response.answer ?? '').isNotEmpty) ...<Widget>[
              Gap.v3,
              Container(
                padding: const EdgeInsets.all(QSpacing.s4),
                decoration: BoxDecoration(
                  color: colors.accentSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AiMarkdown(response.answer!),
              ),
            ],
            Gap.v4,
            for (final SearchResultItem item in response.results) ...<Widget>[
              SearchResultCard(
                item: item,
                onOpen: () => _open(context, ref, item),
                onRelatedTap: (RelatedEntity e) => _openRelated(context, e),
              ),
              Gap.v3,
            ],
          ],
        );
      },
    );
  }

  void _open(BuildContext context, WidgetRef ref, SearchResultItem item) {
    if (navigateToTarget(context, item.navigation)) return;
    // Graph-node / unknown target → show an in-place detail sheet from the item itself.
    showSearchResultSheet(context, item);
  }

  void _openRelated(BuildContext context, RelatedEntity e) {
    final bool went = navigateToTarget(
      context,
      NavigationTarget(kind: e.type, ref: e.id),
    );
    if (!went) {
      QSnackbar.show(context, message: e.name);
    }
  }
}

// ── Save-name prompt ────────────────────────────────────────────────────────────

Future<String?> _promptName(BuildContext context, String initial) {
  final TextEditingController controller = TextEditingController(text: initial);
  return QBottomSheet.show<String>(
    context,
    builder: (BuildContext context) => Padding(
      padding: const EdgeInsets.all(QSpacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Name this search',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Gap.v3,
          QTextField(
            label: 'Name',
            controller: controller,
            autofocus: true,
            maxLength: 120,
          ),
          Gap.v3,
          QButton(
            label: 'Save',
            variant: QButtonVariant.primary,
            block: true,
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    ),
  );
}
