/// The search filters sheet (docs/40 §8.4, docs/41 §14) — sort order, language(s),
/// genre(s), and a reading-time band. Selections apply immediately to the
/// (session-persisted) [SearchFiltersController]; "Reset" clears everything and
/// "Show results" simply closes. Language/genre options come from the shared
/// taxonomy providers (RTL-aware). Presented via the shared [QBottomSheet].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/taxonomy/taxonomy_providers.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/cards/q_chip.dart';
import '../../../../shared/widgets/feedback/q_bottom_sheet.dart';
import '../../domain/value_objects/search_filters.dart';
import '../controllers/search_filters_controller.dart';

/// A reading-time band, in seconds. `null` bounds mean open-ended.
enum _ReadingBand { any, short, medium, long }

extension on _ReadingBand {
  int? get minSeconds => switch (this) {
    _ReadingBand.any || _ReadingBand.short => null,
    _ReadingBand.medium => 300,
    _ReadingBand.long => 900,
  };
  int? get maxSeconds => switch (this) {
    _ReadingBand.short => 300,
    _ReadingBand.medium => 900,
    _ReadingBand.any || _ReadingBand.long => null,
  };
}

Future<void> showSearchFilterSheet(BuildContext context) =>
    QBottomSheet.show<void>(
      context,
      builder: (BuildContext context) => const _SearchFilterSheet(),
    );

class _SearchFilterSheet extends ConsumerWidget {
  const _SearchFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final SearchFilters filters = ref.watch(searchFiltersControllerProvider);
    final controller = ref.read(searchFiltersControllerProvider.notifier);
    final AsyncValue<List<LanguageRef>> languages = ref.watch(
      taxonomyLanguagesProvider,
    );
    final AsyncValue<List<GenreRef>> genres = ref.watch(taxonomyGenresProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s4,
          QSpacing.s5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    l10n.searchFiltersTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: filters.isEmpty ? null : controller.reset,
                    child: Text(l10n.searchFilterReset),
                  ),
                ],
              ),
              Gap.v3,
              _SectionLabel(l10n.searchFilterSortLabel),
              Wrap(
                spacing: QSpacing.s2,
                runSpacing: QSpacing.s2,
                children: <Widget>[
                  for (final SearchSort s in SearchSort.values)
                    QChip(
                      label: _sortLabel(l10n, s),
                      tone: filters.sort == s
                          ? QChipTone.accent
                          : QChipTone.neutral,
                      onTap: () => controller.setSort(s),
                    ),
                ],
              ),
              Gap.v4,
              _SectionLabel(l10n.searchFilterReadingTimeLabel),
              Wrap(
                spacing: QSpacing.s2,
                runSpacing: QSpacing.s2,
                children: <Widget>[
                  for (final _ReadingBand band in _ReadingBand.values)
                    QChip(
                      label: _bandLabel(l10n, band),
                      tone: _isActiveBand(filters, band)
                          ? QChipTone.accent
                          : QChipTone.neutral,
                      onTap: () => controller.setReadingTime(
                        minSeconds: band.minSeconds,
                        maxSeconds: band.maxSeconds,
                      ),
                    ),
                ],
              ),
              Gap.v4,
              _SectionLabel(l10n.searchFilterLanguageLabel),
              _TaxonomyChips(
                async: languages,
                selected: filters.languages,
                labelOf: (LanguageRef l) =>
                    l.nativeName.isNotEmpty ? l.nativeName : l.code,
                valueOf: (LanguageRef l) => l.code,
                onToggle: controller.toggleLanguage,
              ),
              Gap.v4,
              _SectionLabel(l10n.searchFilterGenreLabel),
              _TaxonomyChips(
                async: genres,
                selected: filters.genres,
                labelOf: (GenreRef g) => g.name.isNotEmpty ? g.name : g.slug,
                valueOf: (GenreRef g) => g.slug,
                onToggle: controller.toggleGenre,
              ),
              // The tag filter is only set by tapping a tag result; surface it
              // here so the narrowing is visible and removable on its own.
              if (filters.tag != null) ...<Widget>[
                Gap.v4,
                _SectionLabel(l10n.searchFilterTagLabel),
                Wrap(
                  spacing: QSpacing.s2,
                  runSpacing: QSpacing.s2,
                  children: <Widget>[
                    QChip(
                      label: '#${filters.tag}',
                      tone: QChipTone.accent,
                      onRemove: () => controller.setTag(null),
                    ),
                  ],
                ),
              ],
              Gap.v5,
              SizedBox(
                width: double.infinity,
                child: QButton(
                  label: l10n.searchFilterApply,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isActiveBand(SearchFilters f, _ReadingBand band) =>
      f.minReadingTimeSeconds == band.minSeconds &&
      f.maxReadingTimeSeconds == band.maxSeconds;

  String _sortLabel(AppLocalizations l10n, SearchSort s) => switch (s) {
    SearchSort.relevance => l10n.searchSortRelevance,
    SearchSort.latest => l10n.searchSortLatest,
    SearchSort.trending => l10n.searchSortTrending,
    SearchSort.mostClapped => l10n.searchSortMostClapped,
    SearchSort.mostCommented => l10n.searchSortMostCommented,
  };

  String _bandLabel(AppLocalizations l10n, _ReadingBand band) => switch (band) {
    _ReadingBand.any => l10n.searchReadingAny,
    _ReadingBand.short => l10n.searchReadingShort,
    _ReadingBand.medium => l10n.searchReadingMedium,
    _ReadingBand.long => l10n.searchReadingLong,
  };
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: QSpacing.s2),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _TaxonomyChips<T> extends StatelessWidget {
  const _TaxonomyChips({
    required this.async,
    required this.selected,
    required this.labelOf,
    required this.valueOf,
    required this.onToggle,
  });

  final AsyncValue<List<T>> async;
  final List<String> selected;
  final String Function(T) labelOf;
  final String Function(T) valueOf;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: QSpacing.s2),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (List<T> items) => Wrap(
        spacing: QSpacing.s2,
        runSpacing: QSpacing.s2,
        children: <Widget>[
          for (final T item in items)
            QChip(
              label: labelOf(item),
              tone: selected.contains(valueOf(item))
                  ? QChipTone.accent
                  : QChipTone.neutral,
              onTap: () => onToggle(valueOf(item)),
            ),
        ],
      ),
    );
  }
}
