/// The Search screen (docs/40 §10.2, E8) — a single surface that flows between
/// three phases driven by [SearchQueryController]: the discovery landing (empty query),
/// live autocomplete suggestions (typing), and tabbed results (submitted). It owns
/// the field's [TextEditingController]/[FocusNode] and keeps them in sync with the
/// controller's query so programmatic submits (suggestions, recents, trend chips)
/// update the field. No I/O or business logic here — it composes providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../controllers/recent_searches_controller.dart';
import '../controllers/search_controller.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/search_discovery_view.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/search_results_view.dart';
import '../widgets/search_suggestions_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Best-effort: pull the signed-in user's server-recorded recents.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(recentSearchesControllerProvider.notifier).syncFromServer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncField(String value) {
    if (_controller.text == value) return;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SearchQueryController notifier = ref.read(
      searchQueryControllerProvider.notifier,
    );

    // Keep the field text in sync with programmatic query changes (a tapped
    // suggestion / recent / trend chip, or a clear).
    ref.listen<String>(
      searchQueryControllerProvider.select((SearchState s) => s.rawQuery),
      (String? _, String next) => _syncField(next),
    );
    // Drop the keyboard once a query is submitted so results are unobstructed.
    ref.listen<String>(
      searchQueryControllerProvider.select((SearchState s) => s.submittedQuery),
      (String? previous, String next) {
        if (next.isNotEmpty && next != previous) _focusNode.unfocus();
      },
    );

    final SearchPhase phase = ref.watch(
      searchQueryControllerProvider.select((SearchState s) => s.phase),
    );

    return QScaffold(
      appBar: SearchAppBar(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: notifier.onQueryChanged,
        onSubmitted: (String value) {
          if (!notifier.submit(value)) {
            QSnackbar.show(
              context,
              message: AppLocalizations.of(
                context,
              ).searchTooShortHint(Limits.searchQueryMin),
            );
          }
        },
        onClear: notifier.clear,
        onOpenFilters: () => showSearchFilterSheet(context),
      ),
      body: switch (phase) {
        SearchPhase.discovery => const SearchDiscoveryView(),
        SearchPhase.suggesting => const SearchSuggestionsView(),
        SearchPhase.results => const SearchResultsView(),
      },
    );
  }
}
