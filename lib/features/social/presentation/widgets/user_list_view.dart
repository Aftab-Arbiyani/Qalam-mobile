/// A followers / following list body (docs/40 §8.3) — the shared infinite,
/// pull-to-refresh list of user rows over any `PagedListState<FollowUser>`. Each
/// row is an [AuthorByline] that opens the writer's profile (where an accurate
/// follow button lives — a bare list row lacks the follow relation to seed one).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../../../shared/social/domain/entities/follow_user.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/content/author_byline.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class UserListView extends ConsumerWidget {
  const UserListView({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.emptyTitle,
    required this.emptyBody,
    super.key,
  });

  final AsyncValue<PagedListState<FollowUser>> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagedFeedView<FollowUser>(
      state: state,
      onRefresh: onRefresh,
      onLoadMore: onLoadMore,
      empty: QEmptyState(
        icon: Icons.people_outline,
        title: emptyTitle,
        message: emptyBody,
      ),
      itemBuilder: (BuildContext context, FollowUser user, int index) {
        final String? avatarUrl =
            ref.watch(mediaUrlBuilderProvider).urlForKey(user.avatarKey);
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QSpacing.s4,
            vertical: QSpacing.s2,
          ),
          child: InkWell(
            onTap: () => context.push(Routes.userProfilePath(user.username)),
            child: AuthorByline(
              name: user.displayName,
              handle: user.handle,
              avatarUrl: avatarUrl,
            ),
          ),
        );
      },
    );
  }
}
