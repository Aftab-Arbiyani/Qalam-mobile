/// Collaboration comments screen (AF6) — the threaded discussion on a story. Renders
/// top-level comments with their replies, a capability-gated composer, and a
/// capability-gated resolve action. Distinct from the social (reader) comments on a
/// published piece — these are the collaboration workspace's editorial notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/media/q_avatar.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';

class CollaborationCommentsScreen extends ConsumerWidget {
  const CollaborationCommentsScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
    return Scaffold(
      appBar: const QAppBar(title: 'Comments'),
      body: enabled
          ? _CommentsBody(storyId: storyId)
          : const QEmptyState(
              icon: Icons.mode_comment_outlined,
              title: 'Collaboration is off',
              message:
                  'Enable collaboration to discuss a story with your team.',
            ),
      bottomNavigationBar: enabled
          ? CapabilityGate(
              storyId: storyId,
              action: PolicyAction.storyComment,
              child: _Composer(storyId: storyId),
            )
          : null,
    );
  }
}

class _CommentsBody extends ConsumerWidget {
  const _CommentsBody({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CollaborationComment>> async = ref.watch(
      storyCommentsProvider(storyId),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(storyCommentsProvider(storyId)),
      ),
      data: (List<CollaborationComment> comments) {
        final List<CollaborationComment> threads = comments
            .where((CollaborationComment c) => !c.isReply)
            .toList(growable: false);
        if (threads.isEmpty) {
          return const QEmptyState(
            icon: Icons.forum_outlined,
            title: 'No comments yet',
            message: 'Start the conversation about this story.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(storyCommentsProvider(storyId)),
          child: ListView.separated(
            padding: QSpacing.pagePadding,
            itemCount: threads.length,
            separatorBuilder: (_, _) => Gap.v3,
            itemBuilder: (BuildContext context, int index) =>
                _CommentThread(storyId: storyId, comment: threads[index]),
          ),
        );
      },
    );
  }
}

class _CommentThread extends ConsumerWidget {
  const _CommentThread({required this.storyId, required this.comment});

  final String storyId;
  final CollaborationComment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CommentRow(storyId: storyId, comment: comment, isRoot: true),
          for (final CollaborationComment reply in comment.replies) ...<Widget>[
            const Divider(height: QSpacing.s5),
            Padding(
              padding: const EdgeInsets.only(left: QSpacing.s5),
              child: _CommentRow(
                storyId: storyId,
                comment: reply,
                isRoot: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentRow extends ConsumerWidget {
  const _CommentRow({
    required this.storyId,
    required this.comment,
    required this.isRoot,
  });

  final String storyId;
  final CollaborationComment comment;
  final bool isRoot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            QAvatar(name: comment.authorName ?? comment.authorId, size: 28),
            Gap.h2,
            Expanded(
              child: Text(
                comment.authorName ?? comment.authorId,
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (comment.isInline)
              Chip(
                label: Text(commentKindLabel(comment.kind)),
                visualDensity: VisualDensity.compact,
              ),
            if (comment.isResolved)
              Padding(
                padding: const EdgeInsets.only(left: QSpacing.s1),
                child: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        if (comment.anchor?.quote != null) ...<Widget>[
          Gap.v1,
          Container(
            padding: const EdgeInsets.all(QSpacing.s2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              comment.anchor!.quote!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        Gap.v1,
        Text(comment.body),
        if (isRoot) ...<Widget>[
          Gap.v2,
          Row(
            children: <Widget>[
              if (comment.createdAt != null)
                Text(
                  formatCollaborationDate(comment.createdAt!),
                  style: theme.textTheme.labelSmall,
                ),
              const Spacer(),
              if (!comment.isResolved)
                CapabilityGate(
                  storyId: storyId,
                  action: PolicyAction.commentResolve,
                  child: TextButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Resolve'),
                    onPressed: () async {
                      final CollaborationComment? updated = await ref
                          .read(collaborationControllerProvider.notifier)
                          .resolveComment(comment.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updated == null
                                ? _errorMessage(ref)
                                : 'Comment resolved.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.storyId});

  final String storyId;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String body = _controller.text.trim();
    if (body.isEmpty) return;
    final CollaborationComment? added = await ref
        .read(collaborationControllerProvider.notifier)
        .addComment(storyId: widget.storyId, body: body);
    if (!mounted) return;
    if (added != null) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(ref))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = ref.watch(collaborationControllerProvider).isLoading;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(QSpacing.s3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Add a comment…',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Gap.h2,
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(collaborationControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}
