/// Publishing workflow screen (AF6) — the publish home for a story. Surfaces the
/// review session (request / approve / request-changes), the publish + visibility
/// controls, the snapshot list (create / revert), and the publication history. Every
/// mutating control is wrapped in a [CapabilityGate] on the governing policy action;
/// the server owns the state machine and re-checks on the action.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/cards/q_card.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/collaboration_enums.dart';
import '../../domain/entities/publication_event.dart';
import '../../domain/entities/review_session.dart';
import '../../domain/entities/story_snapshot.dart';
import '../controllers/publishing_controller.dart';
import '../domain_labels.dart';
import '../providers/collaboration_providers.dart';
import '../widgets/capability_gate.dart';

class PublishingWorkflowScreen extends ConsumerWidget {
  const PublishingWorkflowScreen({required this.storyId, super.key});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(appConfigProvider).enableCollaboration;
    return Scaffold(
      appBar: const QAppBar(title: 'Publishing'),
      body: enabled
          ? RefreshIndicator(
              onRefresh: () async {
                ref
                  ..invalidate(storyReviewProvider(storyId))
                  ..invalidate(storySnapshotsProvider(storyId))
                  ..invalidate(publicationHistoryProvider(storyId));
              },
              child: ListView(
                padding: QSpacing.pagePadding,
                children: <Widget>[
                  _ReviewCard(storyId: storyId),
                  Gap.v3,
                  _PublishCard(storyId: storyId),
                  Gap.v3,
                  _SnapshotsCard(storyId: storyId),
                  Gap.v3,
                  _HistoryCard(storyId: storyId),
                ],
              ),
            )
          : const QEmptyState(
              icon: Icons.publish_outlined,
              title: 'Collaboration is off',
              message: 'Enable collaboration to manage the publish workflow.',
            ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<ReviewSession?> async = ref.watch(
      storyReviewProvider(storyId),
    );
    final bool busy = ref.watch(publishingControllerProvider).isLoading;
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Review', style: theme.textTheme.titleMedium),
          Gap.v2,
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(QSpacing.s2),
              child: LinearProgressIndicator(),
            ),
            error: (Object error, StackTrace _) => QErrorView(
              failure: _failureOf(error),
              onRetry: () => ref.invalidate(storyReviewProvider(storyId)),
            ),
            data: (ReviewSession? review) {
              final controller = ref.read(
                publishingControllerProvider.notifier,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text('Status'),
                      const Spacer(),
                      Chip(
                        label: Text(
                          review == null
                              ? reviewStateLabel(ReviewState.draft)
                              : reviewStateLabel(review.state),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  if (review?.notes != null &&
                      review!.notes!.isNotEmpty) ...<Widget>[
                    Gap.v2,
                    Text(review.notes!, style: theme.textTheme.bodySmall),
                  ],
                  Gap.v3,
                  Wrap(
                    spacing: QSpacing.s2,
                    runSpacing: QSpacing.s2,
                    children: <Widget>[
                      if (review == null || !review.isInReview)
                        CapabilityGate(
                          storyId: storyId,
                          action: PolicyAction.storyEdit,
                          child: FilledButton(
                            onPressed: busy
                                ? null
                                : () => _run(
                                    context,
                                    ref,
                                    () => controller.requestReview(
                                      storyId: storyId,
                                    ),
                                    'Review requested.',
                                  ),
                            child: const Text('Request review'),
                          ),
                        ),
                      CapabilityGate(
                        storyId: storyId,
                        action: PolicyAction.reviewApprove,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => _run(
                                      context,
                                      ref,
                                      () => controller.requestChanges(
                                        storyId: storyId,
                                      ),
                                      'Changes requested.',
                                    ),
                              child: const Text('Request changes'),
                            ),
                            Gap.h2,
                            FilledButton(
                              onPressed: busy
                                  ? null
                                  : () => _run(
                                      context,
                                      ref,
                                      () => controller.approveReview(
                                        storyId: storyId,
                                      ),
                                      'Review approved.',
                                    ),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PublishCard extends ConsumerWidget {
  const _PublishCard({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool busy = ref.watch(publishingControllerProvider).isLoading;
    final controller = ref.read(publishingControllerProvider.notifier);
    return CapabilityGate(
      storyId: storyId,
      action: PolicyAction.publicationPublish,
      child: QCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Publication', style: theme.textTheme.titleMedium),
            Gap.v2,
            Text(
              'Publish makes the story visible per its visibility. Unpublish reverts it to a draft.',
              style: theme.textTheme.bodySmall,
            ),
            Gap.v3,
            Wrap(
              spacing: QSpacing.s2,
              runSpacing: QSpacing.s2,
              children: <Widget>[
                FilledButton.icon(
                  icon: const Icon(Icons.publish, size: 18),
                  label: const Text('Publish'),
                  onPressed: busy
                      ? null
                      : () => _run(
                          context,
                          ref,
                          () => controller.publish(storyId: storyId),
                          'Story published.',
                        ),
                ),
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => _run(
                          context,
                          ref,
                          () => controller.unpublish(storyId: storyId),
                          'Story unpublished.',
                        ),
                  child: const Text('Unpublish'),
                ),
              ],
            ),
            Gap.v3,
            Text('Visibility', style: theme.textTheme.labelMedium),
            Gap.v1,
            Wrap(
              spacing: QSpacing.s2,
              children: <Widget>[
                for (final String visibility in StoryVisibility.ordered)
                  ActionChip(
                    label: Text(visibilityLabel(visibility)),
                    onPressed: busy
                        ? null
                        : () => _run(
                            context,
                            ref,
                            () => controller.changeVisibility(
                              storyId: storyId,
                              visibility: visibility,
                            ),
                            'Visibility set to ${visibilityLabel(visibility)}.',
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotsCard extends ConsumerWidget {
  const _SnapshotsCard({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<StorySnapshot>> async = ref.watch(
      storySnapshotsProvider(storyId),
    );
    final bool busy = ref.watch(publishingControllerProvider).isLoading;
    final controller = ref.read(publishingControllerProvider.notifier);
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Snapshots', style: theme.textTheme.titleMedium),
              const Spacer(),
              CapabilityGate(
                storyId: storyId,
                action: PolicyAction.storyEdit,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Capture'),
                  onPressed: busy
                      ? null
                      : () => _run(
                          context,
                          ref,
                          () => controller.createSnapshot(storyId: storyId),
                          'Snapshot captured.',
                        ),
                ),
              ),
            ],
          ),
          Gap.v2,
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(QSpacing.s2),
              child: LinearProgressIndicator(),
            ),
            error: (Object error, StackTrace _) => QErrorView(
              failure: _failureOf(error),
              onRetry: () => ref.invalidate(storySnapshotsProvider(storyId)),
            ),
            data: (List<StorySnapshot> snapshots) {
              if (snapshots.isEmpty) {
                return Text(
                  'No snapshots yet.',
                  style: theme.textTheme.bodySmall,
                );
              }
              return Column(
                children: <Widget>[
                  for (final StorySnapshot snapshot in snapshots)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(snapshot.label),
                      subtitle: Text(
                        // `reason` is why the version exists (publish / manual /
                        // pre_edit / review / restore) — a real wire field the
                        // client used to ignore (P-7).
                        '${formatCollaborationDate(snapshot.createdAt)}'
                        ' · v${snapshot.version}'
                        '${snapshot.reason.isEmpty ? '' : ' · ${snapshotReasonLabel(snapshot.reason)}'}',
                      ),
                      trailing: CapabilityGate(
                        storyId: storyId,
                        action: PolicyAction.storyEdit,
                        child: TextButton(
                          onPressed: busy
                              ? null
                              : () => _run(
                                  context,
                                  ref,
                                  () => controller.revertToSnapshot(
                                    storyId: storyId,
                                    snapshotId: snapshot.id,
                                  ),
                                  'Reverted to snapshot.',
                                ),
                          child: const Text('Revert'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<PublicationEvent>> async = ref.watch(
      publicationHistoryProvider(storyId),
    );
    return QCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Publication history', style: theme.textTheme.titleMedium),
          Gap.v2,
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(QSpacing.s2),
              child: LinearProgressIndicator(),
            ),
            error: (Object error, StackTrace _) => QErrorView(
              failure: _failureOf(error),
              onRetry: () =>
                  ref.invalidate(publicationHistoryProvider(storyId)),
            ),
            data: (List<PublicationEvent> events) {
              if (events.isEmpty) {
                return Text(
                  'No publication events yet.',
                  style: theme.textTheme.bodySmall,
                );
              }
              return Column(
                children: <Widget>[
                  for (final PublicationEvent event in events)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_note_outlined),
                      title: Text(event.type),
                      subtitle: Text(
                        <String?>[
                          event.actorName,
                          formatCollaborationDate(event.createdAt),
                          if (event.visibility != null)
                            visibilityLabel(event.visibility!),
                        ].whereType<String>().join(' · '),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Run a publishing action, then toast the outcome.
Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  Future<Object?> Function() op,
  String okMessage,
) async {
  final Object? result = await op();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result == null ? _errorMessage(ref) : okMessage)),
  );
}

Failure _failureOf(Object error) => error is Failure
    ? error
    : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error');

String _errorMessage(WidgetRef ref) {
  final Object? err = ref.read(publishingControllerProvider).error;
  return err is Failure ? err.message : 'Something went wrong.';
}
