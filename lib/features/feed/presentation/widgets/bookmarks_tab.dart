/// The Bookmarks feed tab (docs/40 §8.3). Reuses the shared paginated feed
/// infrastructure over `GET /me/bookmarks`; requires a signed-in viewer. Kept
/// alive so the list survives tab switches.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../shared/widgets/buttons/q_button.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/bookmark_item.dart';
import '../controllers/bookmarks_controller.dart';
import 'bookmark_card.dart';

class BookmarksTab extends ConsumerStatefulWidget {
  const BookmarksTab({super.key});

  @override
  ConsumerState<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool authed = ref
        .watch(sessionControllerProvider)
        .stateOrUnknown
        .isAuthenticated;
    if (!authed) {
      return QEmptyState(
        icon: Icons.bookmark_border,
        title: 'Keep what moves you.',
        message: 'Sign in to save pieces and find them here.',
        action: QButton(
          label: 'Sign in',
          variant: QButtonVariant.primary,
          onPressed: () =>
              context.push('${Routes.login}?returnTo=${Routes.feed}'),
        ),
      );
    }

    return PagedFeedView<BookmarkItem>(
      state: ref.watch(bookmarksControllerProvider),
      onRefresh: () => ref.read(bookmarksControllerProvider.notifier).refresh(),
      onLoadMore: () =>
          ref.read(bookmarksControllerProvider.notifier).loadMore(),
      empty: const QEmptyState(
        icon: Icons.bookmark_border,
        title: 'No bookmarks yet.',
        message: 'Save a piece while reading and it will wait for you here.',
      ),
      itemBuilder: (BuildContext context, BookmarkItem item, int index) =>
          BookmarkCard(item: item),
    );
  }
}
