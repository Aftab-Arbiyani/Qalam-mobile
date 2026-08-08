/// The drafts screen (M4) — the writer's home under the Write tab. Lists the
/// union of local (offline-first) and server drafts with their sync + lifecycle
/// status, offers pull-to-refresh (retry sync), and a New-piece action that mints a
/// draft and opens the editor. Offline it shows local + last-cached drafts.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/domain/enums.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/radius_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/util/relative_time.dart';
import '../../../../shared/widgets/layout/connectivity_banner.dart';
import '../../../../shared/widgets/media/q_network_image.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../domain/entities/draft_summary.dart';
import '../controllers/draft_list_controller.dart';
import '../providers/writing_providers.dart';
import '../support/piece_limit_copy.dart';
import '../widgets/draft_status_chips.dart';
import '../widgets/piece_limit_notice.dart';

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final AsyncValue<List<DraftSummary>> async = ref.watch(
      draftListControllerProvider,
    );
    // B4 (docs/45 §4.9). Until the allowance is known there is no count and nothing is
    // blocked: the server checks every create anyway, so an unknown allowance costs at
    // worst one refused sync, while holding the action back on every screen open costs
    // every writer who is nowhere near their cap.
    final PieceLimitCopy limit = PieceLimitCopy.of(
      ref.watch(pieceAllowanceProvider).asData?.value,
    );

    return Scaffold(
      backgroundColor: tokens.colors.bgCanvas,
      appBar: AppBar(
        title: const Text('Your writing'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: QSpacing.s4),
            child: Center(child: OfflineChip()),
          ),
        ],
      ),
      // Disabled rather than hidden when the plan is full: a null `onPressed` renders the
      // FAB visibly inert, and the notice below says why. Minting a local draft that
      // could never sync would be worse than refusing it here.
      floatingActionButton: Semantics(
        enabled: !limit.blocked,
        button: true,
        label: limit.blocked
            ? 'New piece, unavailable — your plan’s piece limit is full'
            : 'New piece',
        child: FloatingActionButton.extended(
          onPressed: limit.blocked
              ? null
              : () => unawaited(_newDraft(context, ref)),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('New piece'),
        ),
      ),
      body: Column(
        children: <Widget>[
          const ConnectivityBanner(),
          PieceAllowanceCount(copy: limit),
          PieceLimitNotice(copy: limit),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(draftListControllerProvider.notifier).retrySync(),
              child: async.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) => ListView(
                  children: <Widget>[
                    const SizedBox(height: 120),
                    Center(child: Text('Couldn’t load drafts: $error')),
                  ],
                ),
                data: (List<DraftSummary> drafts) =>
                    _list(context, ref, drafts),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<DraftSummary> drafts) {
    if (drafts.isEmpty) {
      return ListView(
        children: const <Widget>[
          SizedBox(height: 80),
          QEmptyState(
            icon: Icons.edit_note_outlined,
            title: 'Nothing written yet',
            message: 'Tap “New piece” to start your first story.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        QSpacing.s4,
        QSpacing.s3,
        QSpacing.s4,
        QSpacing.s9,
      ),
      itemCount: drafts.length,
      separatorBuilder: (_, _) => const SizedBox(height: QSpacing.s4),
      itemBuilder: (BuildContext context, int index) =>
          _DraftRow(summary: drafts[index]),
    );
  }

  Future<void> _newDraft(BuildContext context, WidgetRef ref) async {
    final String id = await ref
        .read(draftListControllerProvider.notifier)
        .newDraft();
    if (context.mounted) unawaited(context.push(Routes.writeDraftPath(id)));
  }
}

class _DraftRow extends ConsumerWidget {
  const _DraftRow({required this.summary});

  final DraftSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QTokens tokens = QTokens.of(context);
    final String? coverUrl = ref
        .watch(mediaUrlBuilderProvider)
        .urlForKey(summary.coverImageKey);
    final String title = summary.title.trim().isEmpty
        ? 'Untitled'
        : summary.title.trim();

    return Semantics(
      button: true,
      label: '$title, ${summary.status.wire}',
      child: InkWell(
        borderRadius: QRadii.cardRadius,
        onTap: () =>
            unawaited(context.push(Routes.writeDraftPath(summary.routeId))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: QSpacing.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (coverUrl != null) ...<Widget>[
                ClipRRect(
                  borderRadius: QRadii.controlRadius,
                  child: SizedBox(
                    width: 64,
                    height: 48,
                    child: QNetworkImage(url: coverUrl),
                  ),
                ),
                const SizedBox(width: QSpacing.s3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: summary.direction == TextDirectionKind.rtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: tokens.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: QSpacing.s2),
                    Wrap(
                      spacing: QSpacing.s3,
                      runSpacing: QSpacing.s1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        PieceStatusChip(status: summary.status),
                        SyncStateChip(state: summary.syncState),
                        if (summary.updatedAt != null)
                          Text(
                            'Edited ${relativeTime(summary.updatedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    // The one sync failure that "Sync failed" alone would misrepresent:
                    // it will not come good on its own, and the writer can fix it. The
                    // race that reaches here is real — another device (or another tab)
                    // took the last slot after this draft was minted (B4).
                    if (summary.lastError ==
                        ErrorCodes.pieceLimitReached) ...<Widget>[
                      const SizedBox(height: QSpacing.s2),
                      Text(
                        'Not saved — your plan’s piece limit is full. Delete a piece '
                        'to free a slot, or move to a larger plan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.colors.warningText,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            unawaited(context.push(Routes.billingPlans)),
                        child: const Text('See plans'),
                      ),
                    ],
                  ],
                ),
              ),
              _rowMenu(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowMenu(BuildContext context, WidgetRef ref) {
    // Collaboration entries need the SERVER piece id (`storyId === pieceId`), so a
    // draft that has never synced (`remoteId == null`) shows none of them — its
    // local route id would be rejected by the endpoints' `ParseUUIDPipe`
    // (defect **R-1**, `docs/56` §2.4).
    final String? storyId = summary.remoteId;
    final bool collab =
        ref.watch(appConfigProvider).enableCollaboration &&
        storyId != null &&
        storyId.isNotEmpty;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) async {
        switch (value) {
          case 'edit':
            unawaited(context.push(Routes.writeDraftPath(summary.routeId)));
          case 'delete':
            final bool ok = await _confirmDelete(context);
            if (ok) {
              await ref
                  .read(draftListControllerProvider.notifier)
                  .deleteSummary(summary);
            }
          case 'collaborators':
            unawaited(context.push(Routes.storyCollaboratorsPath(storyId!)));
          case 'collab_comments':
            unawaited(context.push(Routes.storyCommentsPath(storyId!)));
          case 'collab_suggestions':
            unawaited(context.push(Routes.storySuggestionsPath(storyId!)));
          case 'collab_publishing':
            unawaited(context.push(Routes.storyPublishingPath(storyId!)));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        if (collab) ...<PopupMenuEntry<String>>[
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'collaborators',
            child: Text('Collaborators'),
          ),
          const PopupMenuItem<String>(
            value: 'collab_comments',
            child: Text('Review comments'),
          ),
          const PopupMenuItem<String>(
            value: 'collab_suggestions',
            child: Text('Suggestions'),
          ),
          const PopupMenuItem<String>(
            value: 'collab_publishing',
            child: Text('Publishing workflow'),
          ),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this draft?'),
        content: const Text("This can't be undone."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
