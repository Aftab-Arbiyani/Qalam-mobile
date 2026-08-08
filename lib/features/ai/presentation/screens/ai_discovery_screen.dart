/// AI Discovery hub (AF4) — the entry point: a tap-through search bar + explainable
/// recommendation shelves (trending, for-you, continue reading, authors, genres). Every
/// card is produced + explained by the backend Recommendation Engine; the client only
/// renders and navigates. Session-gated (`/ai` prefix) + the AI compile flag.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/color_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/loading/q_skeleton.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/ai_feature_flag.dart';
import '../../domain/entities/retrieval.dart';
import '../../domain/value_objects/retrieval_vocab.dart';
import '../controllers/recommendations_controller.dart';
import '../providers/ai_providers.dart';
import '../widgets/retrieval_cards.dart';
import '../widgets/retrieval_navigation.dart';

class AiDiscoveryScreen extends ConsumerWidget {
  const AiDiscoveryScreen({super.key});

  static const List<RecommendationKind> _shelves = <RecommendationKind>[
    RecommendationKind.trending,
    RecommendationKind.feed,
    RecommendationKind.continueReading,
    RecommendationKind.authors,
    RecommendationKind.genres,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// **B5 (`platfrom/docs/45` §4.10).** This screen used to read the compile-time
    /// [AppConfig.enableAi] kill switch ALONE, which meant a writer who turned AI off for
    /// their account still got a full "Discover with AI" hub whose every shelf then 403'd.
    /// The server's answer is the runtime source of truth for gating (`GET /ai/features`),
    /// so the account's switch is ANDed in here.
    ///
    /// A gate read that has not resolved yet is treated as ON (`?? true`): flashing the
    /// off-state and then filling in reads as a broken screen, and every shelf below
    /// resolves its own failure honestly anyway.
    final AiFeatures? aiFeatures = ref.watch(aiFeaturesProvider).asData?.value;
    final bool enabled =
        ref.watch(appConfigProvider).enableAi &&
        (aiFeatures?.aiEnabled ?? true);
    return QScaffold(
      appBar: const QAppBar(title: 'Discover with AI'),
      body: enabled
          ? ListView(
              padding: const EdgeInsets.symmetric(vertical: QSpacing.s4),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: QSpacing.s4),
                  child: _SearchBarButton(
                    onTap: () => context.push(Routes.aiSearch),
                  ),
                ),
                Gap.v4,
                for (final RecommendationKind kind in _shelves)
                  _RecommendationShelf(kind: kind),
              ],
            )
          : const QEmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'AI discovery is off',
              message:
                  'Turn AI on in Settings \u203A AI to explore recommendations.',
            ),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QColorSet colors = QTokens.of(context).colors;
    final TextTheme text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Search stories and characters with AI',
      child: QCard(
        padding: QCardPadding.md,
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Icon(Icons.search, color: colors.textMuted),
            Gap.h2,
            Text(
              'Ask or search across your stories…',
              style: text.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationShelf extends ConsumerWidget {
  const _RecommendationShelf({required this.kind});

  final RecommendationKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RecommendationResponse> async = ref.watch(
      recommendationsProvider((kind: kind, storyId: null, pieceId: null)),
    );

    // A shelf that fails or is empty simply hides itself — the hub stays calm.
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
          child: Text(kind.label, style: text.titleMedium),
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
