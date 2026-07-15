/// One piece-summary feed tab (docs/40 §8.3, docs/41 §17). Watches the shared
/// [FeedListController] family for its [FeedTab] and renders the shared
/// [PagedFeedView]. Kept alive so switching tabs preserves scroll + loaded pages.
/// The Following tab requires a signed-in viewer; anonymous users get a calm
/// sign-in prompt instead of an error.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/piece_summary.dart';
import '../../domain/value_objects/feed_query.dart';
import '../controllers/feed_list_controller.dart';
import 'feed_skeleton_list.dart';
import 'paged_feed_view.dart';
import 'piece_card.dart';

class PieceFeedTab extends ConsumerStatefulWidget {
  const PieceFeedTab({required this.tab, super.key});

  final FeedTab tab;

  @override
  ConsumerState<PieceFeedTab> createState() => _PieceFeedTabState();
}

class _PieceFeedTabState extends ConsumerState<PieceFeedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.tab.requiresAuth) {
      final bool authed = ref
          .watch(sessionControllerProvider)
          .stateOrUnknown
          .isAuthenticated;
      if (!authed) return const _SignInPrompt();
    }

    final controller = feedListControllerProvider(widget.tab);
    return PagedFeedView<PieceSummary>(
      state: ref.watch(controller),
      onRefresh: () => ref.read(controller.notifier).refresh(),
      onLoadMore: () => ref.read(controller.notifier).loadMore(),
      loading: const FeedSkeletonList(),
      empty: QEmptyState(
        icon: Icons.menu_book_outlined,
        title: _emptyTitle(widget.tab),
        message: _emptyMessage(widget.tab),
      ),
      itemBuilder: (BuildContext context, PieceSummary piece, int index) =>
          PieceCard(piece: piece),
    );
  }

  String _emptyTitle(FeedTab tab) => switch (tab) {
    FeedTab.following => 'No pieces yet from those you follow.',
    FeedTab.forYou => 'Nothing to suggest just yet.',
    FeedTab.trending => 'Nothing is trending right now.',
    FeedTab.latest => 'No pieces have been published yet.',
  };

  String _emptyMessage(FeedTab tab) => switch (tab) {
    FeedTab.following =>
      'Follow a few writers and their work will gather here.',
    FeedTab.forYou => 'As you read, fresh voices will appear here.',
    FeedTab.trending =>
      'Check back soon for what readers are gathering around.',
    FeedTab.latest => 'When writers publish, their newest pieces land here.',
  };
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return QEmptyState(
      icon: Icons.people_outline,
      title: 'Follow the writers you love.',
      message: 'Sign in to gather the newest work from writers you follow.',
      action: QButton(
        label: 'Sign in',
        variant: QButtonVariant.primary,
        onPressed: () =>
            context.push('${Routes.login}?returnTo=${Routes.feed}'),
      ),
    );
  }
}
