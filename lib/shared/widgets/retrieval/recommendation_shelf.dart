/// A horizontal shelf of explainable recommendations.
///
/// This was `_RecommendationShelf`, private to the "Discover with AI" hub that **D5**
/// deleted. The hub was the mistake, not the shelf: it put recommendations behind a
/// door labelled with the technology instead of putting them where a reader is already
/// browsing. So the shelf became public and moved onto `/discover`, beside the shelves
/// that were always there.
///
/// **It hides itself when it has nothing.** Empty, errored, or signed-out all render
/// the same nothing — a shelf that announces its own failure to a reader who never
/// asked for it is noise, and `/discover` has real content above and below it.
///
/// Recommendations are auth-only, so for an anonymous reader
/// [recommendationsProvider] answers empty without reaching the network. Callers should
/// still not mount this for them: see `platfrom/docs/48` §3.25 for what an authenticated
/// read on a public page costs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../retrieval/domain/retrieval.dart';
import '../../retrieval/domain/retrieval_vocab.dart';
import '../../retrieval/retrieval_providers.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../loading/q_skeleton.dart';
import 'retrieval_cards.dart';
import 'retrieval_navigation.dart';

class RecommendationShelf extends ConsumerWidget {
  const RecommendationShelf({
    required this.kind,
    this.title,
    this.storyId,
    this.pieceId,
    super.key,
  });

  final RecommendationKind kind;

  /// Overrides [RecommendationKind.label] when a surface wants its own heading.
  final String? title;
  final String? storyId;
  final String? pieceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RecommendationResponse> async = ref.watch(
      recommendationsProvider((kind: kind, storyId: storyId, pieceId: pieceId)),
    );

    return async.when(
      skipLoadingOnRefresh: true,
      loading: () => _shelf(context, const _ShelfSkeleton()),
      error: (_, _) => const SizedBox.shrink(),
      data: (RecommendationResponse r) => r.items.isEmpty
          ? const SizedBox.shrink()
          : _shelf(context, _horizontalList(context, r.items)),
    );
  }

  Widget _shelf(BuildContext context, Widget body) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            QSpacing.s4,
            QSpacing.s2,
            QSpacing.s4,
            QSpacing.s2,
          ),
          child: Text(title ?? kind.label, style: text.titleMedium),
        ),
        body,
        Gap.v4,
      ],
    );
  }

  Widget _horizontalList(BuildContext context, List<RecommendationItem> items) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
        itemCount: items.length,
        separatorBuilder: (_, _) => Gap.h3,
        itemBuilder: (BuildContext context, int i) {
          final RecommendationItem item = items[i];
          return SizedBox(
            width: 260,
            child: RecommendationCard(
              item: item,
              compact: true,
              onOpen: () => navigateToTarget(context, item.navigation),
            ),
          );
        },
      ),
    );
  }
}

class _ShelfSkeleton extends StatelessWidget {
  const _ShelfSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
        itemCount: 3,
        separatorBuilder: (_, _) => Gap.h3,
        itemBuilder: (_, _) => const SizedBox(
          width: 260,
          child: QSkeleton(height: 160, width: 260),
        ),
      ),
    );
  }
}
