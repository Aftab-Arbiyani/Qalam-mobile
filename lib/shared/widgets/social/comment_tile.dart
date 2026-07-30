/// A comment node in the thread (docs/40 §21.4, docs/41 §35) — byline + body +
/// a quiet action row (reply / edit / delete / report), an inline reply or edit
/// composer, and — for a top-level comment — an expandable replies list (one
/// indent level; deeper server nesting is flattened for readability). A
/// soft-deleted node renders the tombstone but keeps its replies. Own vs. other
/// is decided from the current user. Accessible: each node is a labelled region,
/// actions are semantic buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/session/current_user_controller.dart';
import '../../../core/session/session_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../domain/enums.dart';
import '../../motion/motion.dart';
import '../../pagination/paged_list_state.dart';
import '../../social/domain/entities/comment.dart';
import '../../social/presentation/controllers/comments_controller.dart';
import '../../theme/q_tokens.dart';
import '../../theme/tokens/motion_tokens.dart';
import '../../theme/tokens/spacing_tokens.dart';
import '../../util/relative_time.dart';
import '../content/author_byline.dart';
import '../feedback/q_dialog.dart';
import 'comment_composer.dart';
import 'report_sheet.dart';

class CommentTile extends ConsumerStatefulWidget {
  const CommentTile({
    required this.comment,
    required this.pieceId,
    this.isReply = false,
    super.key,
  });

  final Comment comment;
  final String pieceId;
  final bool isReply;

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _showReplies = false;
  bool _replying = false;
  bool _editing = false;

  Comment get _c => widget.comment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QTokens tokens = QTokens.of(context);
    final ThemeData theme = Theme.of(context);
    final bool authed =
        ref.watch(sessionControllerProvider).stateOrUnknown.isAuthenticated;
    final me = ref.watch(currentUserControllerProvider);
    final bool isOwn =
        me != null && _c.author?.username == me.username && !_c.isDeleted;
    final String? avatarUrl =
        ref.watch(mediaUrlBuilderProvider).urlForKey(_c.author?.avatarKey);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: widget.isReply ? QSpacing.s6 : QSpacing.s4,
        end: QSpacing.s4,
        top: QSpacing.s2,
        bottom: QSpacing.s2,
      ),
      child: Semantics(
        container: true,
        label: _c.isDeleted
            ? l10n.commentDeletedTombstone
            : '${_c.author?.displayName ?? ''}: ${_c.body}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AuthorByline(
              name: _c.author?.displayName ?? '—',
              handle: _c.author?.handle ?? '',
              avatarUrl: avatarUrl,
              avatarSize: widget.isReply ? 24 : 32,
              meta: _c.createdAt == null ? null : relativeTime(_c.createdAt!),
            ),
            Gap.v1,
            if (_editing && isOwn)
              CommentComposer(
                hint: l10n.commentComposerHint,
                sendLabel: l10n.commentSend,
                autofocus: true,
                onSubmit: _submitEdit,
              )
            else
              Text(
                _c.isDeleted ? l10n.commentDeletedTombstone : _c.body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _c.isDeleted
                      ? tokens.colors.textMuted
                      : tokens.colors.textPrimary,
                  fontStyle: _c.isDeleted ? FontStyle.italic : null,
                ),
              ),
            if (_c.wasEdited && !_c.isDeleted)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.commentEdited,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textMuted,
                  ),
                ),
              ),
            if (!_c.isDeleted) _actions(l10n, tokens, authed: authed, isOwn: isOwn),
            if (_replying && authed)
              CommentComposer(
                hint: l10n.commentReplyHint,
                sendLabel: l10n.commentReply,
                autofocus: true,
                onSubmit: _submitReply,
              ),
            if (!widget.isReply) _replies(l10n),
          ],
        ),
      ),
    );
  }

  Widget _actions(
    AppLocalizations l10n,
    QTokens tokens, {
    required bool authed,
    required bool isOwn,
  }) {
    return Wrap(
      spacing: QSpacing.s1,
      children: <Widget>[
        if (!widget.isReply && authed)
          _ActionText(
            label: l10n.commentReply,
            onTap: () => setState(() => _replying = !_replying),
          ),
        if (isOwn)
          _ActionText(
            label: l10n.commentEdit,
            onTap: () => setState(() => _editing = !_editing),
          ),
        if (isOwn)
          _ActionText(label: l10n.commentDelete, onTap: _confirmDelete),
        if (authed && !isOwn)
          _ActionText(
            label: l10n.reportTitle,
            onTap: () => showReportSheet(
              context,
              entityType: ReportEntityType.comment,
              entityId: _c.id,
              title: l10n.reportCommentTitle,
            ),
          ),
      ],
    );
  }

  Widget _replies(AppLocalizations l10n) {
    if (_c.replyCount == 0 && !_showReplies) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ActionText(
          label: _showReplies
              ? l10n.commentHideReplies
              : l10n.commentViewReplies(_c.replyCount),
          onTap: () => setState(() => _showReplies = !_showReplies),
        ),
        AnimatedSize(
          duration: Motion.duration(context, QDurations.fast),
          curve: QCurves.standard,
          alignment: Alignment.topCenter,
          child: _showReplies
              ? _RepliesList(parentId: _c.id, pieceId: widget.pieceId)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Future<bool> _submitReply(String body) async {
    await ref
        .read(repliesControllerProvider(_c.id).notifier)
        .add(body);
    if (mounted) setState(() => _replying = false);
    return true;
  }

  Future<bool> _submitEdit(String body) async {
    if (widget.isReply && _c.parentId != null) {
      await ref
          .read(repliesControllerProvider(_c.parentId!).notifier)
          .edit(_c.id, body);
    } else {
      await ref
          .read(commentsControllerProvider(widget.pieceId).notifier)
          .edit(_c.id, body);
    }
    if (mounted) setState(() => _editing = false);
    return true;
  }

  Future<void> _confirmDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await QDialog.confirm(
      context,
      title: l10n.commentDeleteConfirmTitle,
      message: l10n.commentDeleteConfirmBody,
      confirmLabel: l10n.commentDelete,
      destructive: true,
    );
    if (!ok) return;
    if (widget.isReply && _c.parentId != null) {
      await ref
          .read(repliesControllerProvider(_c.parentId!).notifier)
          .delete(_c.id);
    } else {
      await ref
          .read(commentsControllerProvider(widget.pieceId).notifier)
          .delete(_c.id);
    }
  }
}

/// The inline replies list under a top-level comment.
class _RepliesList extends ConsumerWidget {
  const _RepliesList({required this.parentId, required this.pieceId});

  final String parentId;
  final String pieceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PagedListState<Comment>> state = ref.watch(
      repliesControllerProvider(parentId),
    );
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(QSpacing.s3),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (PagedListState<Comment> paged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final Comment reply in paged.items)
            CommentTile(comment: reply, pieceId: pieceId, isReply: true),
          if (paged.hasMore)
            _ActionText(
              label: '＋',
              onTap: () =>
                  ref.read(repliesControllerProvider(parentId).notifier).loadMore(),
            ),
        ],
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QTokens tokens = QTokens.of(context);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: QSpacing.s1,
            horizontal: QSpacing.s1,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tokens.colors.accent,
            ),
          ),
        ),
      ),
    );
  }
}
