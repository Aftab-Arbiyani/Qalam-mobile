/// Collaboration comments screen (AF6) — the threaded discussion on a story. Renders
/// top-level comments with their replies, a capability-gated composer, and a
/// capability-gated resolve action. Distinct from the social (reader) comments on a
/// published piece — these are the collaboration workspace's editorial notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/domain/limits.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../../profile/presentation/widgets/actor_identity.dart';
import '../../domain/entities/collaboration_comment.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../controllers/collaboration_controller.dart';
import '../domain_labels.dart';
import '../mention_text.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';
import '../widgets/mention_body.dart';
import '../widgets/mention_field.dart';

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
    final AsyncValue<CursorPage<CollaborationComment>> async = ref.watch(
      storyCommentsProvider(storyId),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(storyCommentsProvider(storyId)),
      ),
      data: (CursorPage<CollaborationComment> page) {
        // The endpoint returns ROOT comments only (`listRootComments`), so no
        // client-side filtering is needed — and replies are a separate read (C-5).
        final List<CollaborationComment> threads = page.items;
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

/// A root comment with its replies fetched on demand.
///
/// `CommentDto` has no `replies` field — the list endpoint returns roots only and a
/// thread comes from `GET /comments/:id/thread`. The screen used to iterate a
/// `replies` array that was always empty, so no thread could ever render
/// (defect **C-5**, `docs/56` §2.1).
class _CommentThread extends ConsumerStatefulWidget {
  const _CommentThread({required this.storyId, required this.comment});

  final String storyId;
  final CollaborationComment comment;

  @override
  ConsumerState<_CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<_CommentThread> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return QCard(
      padding: QCardPadding.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CommentRow(
            storyId: widget.storyId,
            comment: widget.comment,
            isRoot: true,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.forum_outlined,
                size: 18,
              ),
              label: Text(_expanded ? 'Hide replies' : 'Replies'),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            _Replies(storyId: widget.storyId, rootId: widget.comment.id),
        ],
      ),
    );
  }
}

/// The replies half of a thread (`CommentThreadDto.replies`) plus a composer.
class _Replies extends ConsumerWidget {
  const _Replies({required this.storyId, required this.rootId});

  final String storyId;
  final String rootId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CommentThread> async = ref.watch(
      storyCommentThreadProvider(rootId),
    );
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(QSpacing.s2),
        child: LinearProgressIndicator(),
      ),
      error: (Object error, StackTrace _) => QErrorView(
        failure: _failureOf(error),
        onRetry: () => ref.invalidate(storyCommentThreadProvider(rootId)),
      ),
      data: (CommentThread thread) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (thread.replies.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: QSpacing.s5),
              child: Text(
                'No replies yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          for (final CollaborationComment reply in thread.replies) ...<Widget>[
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
          Gap.v2,
          CapabilityGate(
            storyId: storyId,
            action: PolicyAction.storyComment,
            child: _ReplyComposer(storyId: storyId, rootId: rootId),
          ),
        ],
      ),
    );
  }
}

/// Posts to `POST /comments/:id/replies` — `{body, mentions?}`. This is the only
/// way to create a reply; `parentId` on the create-comment body is not accepted
/// (C-7).
///
/// Mentions ride the reply endpoint exactly as they do the root one (P-2) — the
/// contract carries `mentions` on both DTOs, so a row that only did root comments
/// would leave half the surface silently unable to notify anyone.
class _ReplyComposer extends ConsumerStatefulWidget {
  const _ReplyComposer({required this.storyId, required this.rootId});

  final String storyId;
  final String rootId;

  @override
  ConsumerState<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends ConsumerState<_ReplyComposer> {
  final TextEditingController _controller = TextEditingController();
  List<MentionCandidate> _mentions = const <MentionCandidate>[];

  @override
  void initState() {
    super.initState();
    // Deleting or editing a mention un-mentions the person, so the ids sent stay
    // true to the text as it now reads.
    _controller.addListener(_prune);
  }

  @override
  void dispose() {
    _controller.removeListener(_prune);
    _controller.dispose();
    super.dispose();
  }

  void _prune() {
    final List<MentionCandidate> next = pruneMentions(
      _controller.text,
      _mentions,
    );
    if (next.length != _mentions.length) setState(() => _mentions = next);
  }

  Future<void> _submit() async {
    final RawCommentBody raw = toRawCommentBody(
      _controller.text.trim(),
      _mentions,
    );
    if (raw.body.isEmpty) return;
    if (raw.body.length > Limits.storyCommentBodyMax) return;
    final CollaborationComment? added = await ref
        .read(collaborationControllerProvider.notifier)
        .replyToComment(
          commentId: widget.rootId,
          body: raw.body,
          mentions: raw.mentions,
        );
    if (!mounted) return;
    if (added != null) {
      _controller.clear();
      setState(() => _mentions = const <MentionCandidate>[]);
      ref.invalidate(storyCommentThreadProvider(widget.rootId));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(ref))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: QSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: MentionField(
                  storyId: widget.storyId,
                  controller: _controller,
                  semanticLabel: 'Reply',
                  hintText: 'Reply…',
                  maxLines: 3,
                  isDense: true,
                  onMention: (MentionCandidate candidate) => setState(() {
                    if (!_mentions.contains(candidate)) {
                      _mentions = <MentionCandidate>[..._mentions, candidate];
                    }
                  }),
                ),
              ),
              Gap.h2,
              IconButton(
                icon: const Icon(Icons.send, size: 18),
                onPressed: _submit,
              ),
            ],
          ),
          _RawBodyCounter(controller: _controller, mentions: _mentions),
        ],
      ),
    );
  }
}

/// The character count, measured on the RAW body.
///
/// `@MaxLength(MAX_COMMENT_BODY_LENGTH)` is applied server-side to the string that
/// contains the **ids**, where each mention is 37 characters rather than the handful
/// the writer can see. A counter over the visible text would let someone past a limit
/// the server then rejects, with nothing on screen to explain the gap — so this reads
/// [rawCommentBodyLength], and says out loud why the number is larger than the text
/// once a mention is in play.
class _RawBodyCounter extends StatelessWidget {
  const _RawBodyCounter({required this.controller, required this.mentions});

  final TextEditingController controller;
  final List<MentionCandidate> mentions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? _) {
        final int length = rawCommentBodyLength(value.text.trim(), mentions);
        final bool over = length > Limits.storyCommentBodyMax;
        // Silent until it can matter: with no mention and plenty of room there is
        // nothing surprising to explain.
        if (mentions.isEmpty && length < Limits.storyCommentBodyMax - 200) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: QSpacing.s1),
          child: Text(
            mentions.isEmpty
                ? '$length / ${Limits.storyCommentBodyMax}'
                : '$length / ${Limits.storyCommentBodyMax} — each mention counts as '
                      'the person’s id, not their name.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: over ? theme.colorScheme.error : null,
            ),
          ),
        );
      },
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
            // `CommentDto` carries `authorId` and no name, so the author is
            // resolved by id (B3) — the same lookup every other actor uses.
            ActorAvatar(userId: comment.authorId, size: 28),
            Gap.h2,
            Expanded(
              child: ActorName(
                userId: comment.authorId,
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
        // A stored `@<uuid>` resolves to a name here — the render half of P-2, without
        // which the composer would be writing ids into prose nobody turns back into
        // people.
        MentionBody(body: comment.body, style: theme.textTheme.bodyMedium),
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
  List<MentionCandidate> _mentions = const <MentionCandidate>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_prune);
  }

  @override
  void dispose() {
    _controller.removeListener(_prune);
    _controller.dispose();
    super.dispose();
  }

  void _prune() {
    final List<MentionCandidate> next = pruneMentions(
      _controller.text,
      _mentions,
    );
    if (next.length != _mentions.length) setState(() => _mentions = next);
  }

  Future<void> _submit() async {
    // The handles the writer sees become the `@<uuid>` the wire stores, here and
    // nowhere else (P-2). `mentions` is belt-and-braces: the server re-derives the
    // same ids from the same body and unions the two.
    final RawCommentBody raw = toRawCommentBody(
      _controller.text.trim(),
      _mentions,
    );
    if (raw.body.isEmpty) return;
    if (raw.body.length > Limits.storyCommentBodyMax) return;
    final CollaborationComment? added = await ref
        .read(collaborationControllerProvider.notifier)
        .addComment(
          storyId: widget.storyId,
          body: raw.body,
          mentions: raw.mentions,
        );
    if (!mounted) return;
    if (added != null) {
      _controller.clear();
      setState(() => _mentions = const <MentionCandidate>[]);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: MentionField(
                    storyId: widget.storyId,
                    controller: _controller,
                    semanticLabel: 'Comment',
                    hintText: 'Add a comment…',
                    onMention: (MentionCandidate candidate) => setState(() {
                      if (!_mentions.contains(candidate)) {
                        _mentions = <MentionCandidate>[..._mentions, candidate];
                      }
                    }),
                  ),
                ),
                Gap.h2,
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: busy ? null : _submit,
                ),
              ],
            ),
            _RawBodyCounter(controller: _controller, mentions: _mentions),
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
