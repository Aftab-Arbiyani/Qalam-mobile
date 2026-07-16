/// The comments screen (docs/40 §21.4) — a piece's full comment thread: an
/// infinite, pull-to-refresh list of top-level [CommentTile]s (each expandable to
/// its replies), a client-side newest/oldest sort, and a pinned composer for
/// signed-in readers. Reuses the shared [PagedFeedView] + comment widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/pagination/paged_list_state.dart';
import '../../../../shared/social/domain/entities/comment.dart';
import '../../../../shared/social/presentation/controllers/comments_controller.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/layout/q_scaffold.dart';
import '../../../../shared/widgets/list/paged_feed_view.dart';
import '../../../../shared/widgets/loading/feed_skeleton_list.dart';
import '../../../../shared/widgets/social/comment_composer.dart';
import '../../../../shared/widgets/social/comment_tile.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({required this.pieceId, super.key});

  final String pieceId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  bool _newestFirst = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final provider = commentsControllerProvider(widget.pieceId);
    final bool authed =
        ref.watch(sessionControllerProvider).stateOrUnknown.isAuthenticated;

    final AsyncValue<PagedListState<Comment>> sorted = ref
        .watch(provider)
        .whenData(
          (PagedListState<Comment> p) => p.copyWith(
            items: <Comment>[...p.items]..sort(
              (Comment a, Comment b) {
                final DateTime an =
                    a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final DateTime bn =
                    b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return _newestFirst ? bn.compareTo(an) : an.compareTo(bn);
              },
            ),
          ),
        );

    return QScaffold(
      appBar: QAppBar(
        title: l10n.commentsTitle,
        actions: <Widget>[
          TextButton(
            onPressed: () => setState(() => _newestFirst = !_newestFirst),
            child: Text(
              _newestFirst ? l10n.commentSortNewest : l10n.commentSortOldest,
            ),
          ),
        ],
      ),
      body: PagedFeedView<Comment>(
        state: sorted,
        loading: const FeedSkeletonList(count: 4),
        onRefresh: () => ref.read(provider.notifier).refresh(),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        empty: QEmptyState(
          icon: Icons.mode_comment_outlined,
          title: l10n.commentsEmptyTitle,
          message: l10n.commentsEmptyBody,
        ),
        itemBuilder: (BuildContext context, Comment comment, int index) =>
            CommentTile(comment: comment, pieceId: widget.pieceId),
      ),
      bottomNavigationBar: authed
          ? _ComposerBar(
              child: CommentComposer(
                hint: l10n.commentComposerHint,
                sendLabel: l10n.commentSend,
                onSubmit: (String body) async {
                  await ref.read(provider.notifier).add(body);
                  return true;
                },
              ),
            )
          : _SignInBar(message: l10n.commentSignInPrompt),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.colors.bgCanvas,
          border: Border(top: BorderSide(color: tokens.colors.border)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SignInBar extends StatelessWidget {
  const _SignInBar({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(QSpacing.s4),
        decoration: BoxDecoration(
          color: tokens.colors.bgRaised,
          border: Border(top: BorderSide(color: tokens.colors.border)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: tokens.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
