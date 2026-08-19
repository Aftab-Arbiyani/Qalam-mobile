/// AI conversations screen (AF2) — the caller's conversation history over the reused
/// AF1 API: search (client-side filter), pin (on-device), rename, archive, delete, and
/// tap-through to continue. Pinned conversations sort first. Cursor-paginated.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/states/q_empty_state.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/ai_conversation.dart';
import '../controllers/conversations_controller.dart';

class AiConversationsScreen extends ConsumerStatefulWidget {
  const AiConversationsScreen({super.key});

  @override
  ConsumerState<AiConversationsScreen> createState() =>
      _AiConversationsScreenState();
}

class _AiConversationsScreenState extends ConsumerState<AiConversationsScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      unawaited(ref.read(conversationsControllerProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ConversationsState> async = ref.watch(
      conversationsControllerProvider,
    );
    return Scaffold(
      appBar: QAppBar(
        title: 'AI conversations',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Discover with AI',
            onPressed: () => context.push(Routes.aiDiscovery),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(
                  code: ErrorCodes.apiUnexpected,
                  message: '$error',
                ),
          onRetry: () => ref.invalidate(conversationsControllerProvider),
        ),
        data: _content,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => unawaited(_startConversation()),
        icon: const Icon(Icons.add),
        label: const Text('New conversation'),
      ),
    );
  }

  Future<void> _startConversation() async {
    final AiConversationSummary? created = await ref
        .read(conversationsControllerProvider.notifier)
        .create();
    if (!mounted) return;
    if (created == null) {
      QSnackbar.show(
        context,
        message: 'Couldn’t start a conversation.',
        variant: QSnackbarVariant.danger,
      );
      return;
    }
    unawaited(context.push(Routes.aiConversationPath(created.id)));
  }

  Widget _content(ConversationsState state) {
    final List<AiConversationSummary> rows = _query.isEmpty
        ? state.ordered
        : state.ordered
              .where(
                (AiConversationSummary c) =>
                    c.displayTitle.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList(growable: false);

    return Column(
      children: <Widget>[
        // Two views of one collection, so a SegmentedButton rather than two buttons — it announces
        // the selection to TalkBack/VoiceOver, which a pair of plain buttons does not. Switching
        // clears the search: it filters only the rows paged in, so a needle carried across a shelf
        // change would hide most of the shelf just arrived at.
        Padding(
          padding: QSpacing.pagePadding,
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<AiConversationStatus>(
              segments: const <ButtonSegment<AiConversationStatus>>[
                ButtonSegment<AiConversationStatus>(
                  value: AiConversationStatus.active,
                  label: Text('Active'),
                ),
                ButtonSegment<AiConversationStatus>(
                  value: AiConversationStatus.archived,
                  label: Text('Archived'),
                ),
              ],
              selected: <AiConversationStatus>{state.shelf},
              showSelectedIcon: false,
              onSelectionChanged: (Set<AiConversationStatus> next) {
                _search.clear();
                setState(() => _query = '');
                unawaited(
                  ref
                      .read(conversationsControllerProvider.notifier)
                      .setShelf(next.first),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: QSpacing.pagePadding,
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search conversations',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (String v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? QEmptyState(
                  icon: state.isArchivedShelf
                      ? Icons.archive_outlined
                      : Icons.forum_outlined,
                  // "No conversations yet" would be false on an empty archive whenever the active
                  // shelf has rows, which is the common case.
                  title: state.isArchivedShelf
                      ? 'Nothing archived'
                      : 'No conversations yet',
                  message: state.isArchivedShelf
                      ? 'Archived conversations are kept here, out of the active list, until you restore or delete them.'
                      : 'Your AI conversations will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(conversationsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    itemCount: rows.length,
                    itemBuilder: (BuildContext context, int i) => _row(
                      rows[i],
                      state.isPinned(rows[i].id),
                      state.isArchivedShelf,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _row(AiConversationSummary c, bool pinned, bool archivedShelf) {
    final QTokens tokens = QTokens.of(context);
    return ListTile(
      leading: Icon(
        pinned ? Icons.push_pin : Icons.chat_bubble_outline,
        color: pinned ? tokens.colors.accent : tokens.colors.textMuted,
      ),
      title: Text(c.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${c.messageCount} messages · ${_date(c.updatedAt)}'),
      trailing: PopupMenuButton<String>(
        onSelected: (String v) => unawaited(_onAction(v, c)),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'pin',
            child: Text(pinned ? 'Unpin' : 'Pin'),
          ),
          const PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
          // Archive on the active shelf, Restore on the archived one — the same row cannot offer
          // both, and offering only Archive is what made it a one-way trip.
          PopupMenuItem<String>(
            value: archivedShelf ? 'restore' : 'archive',
            child: Text(archivedShelf ? 'Restore' : 'Archive'),
          ),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => unawaited(context.push(Routes.aiConversationPath(c.id))),
    );
  }

  Future<void> _onAction(String action, AiConversationSummary c) async {
    final ConversationsController notifier = ref.read(
      conversationsControllerProvider.notifier,
    );
    switch (action) {
      case 'pin':
        await notifier.togglePin(c.id);
      case 'rename':
        final String? title = await _renameDialog(c.displayTitle);
        if (title != null && title.trim().isNotEmpty) {
          final bool ok = await notifier.rename(c.id, title.trim());
          if (mounted && !ok) {
            QSnackbar.show(
              context,
              message: 'Rename failed.',
              variant: QSnackbarVariant.danger,
            );
          }
        }
      case 'archive':
        final bool archived = await notifier.archive(c.id);
        if (mounted) {
          QSnackbar.show(
            context,
            message: archived ? 'Archived.' : 'Couldn’t archive.',
            variant: archived
                ? QSnackbarVariant.neutral
                : QSnackbarVariant.danger,
          );
        }
      case 'restore':
        final bool restored = await notifier.restore(c.id);
        if (mounted) {
          QSnackbar.show(
            context,
            message: restored ? 'Restored.' : 'Couldn’t restore.',
            variant: restored
                ? QSnackbarVariant.neutral
                : QSnackbarVariant.danger,
          );
        }
      case 'delete':
        final bool ok = await notifier.delete(c.id);
        if (mounted) {
          QSnackbar.show(
            context,
            message: ok ? 'Conversation deleted.' : 'Delete failed.',
            variant: ok ? QSnackbarVariant.neutral : QSnackbarVariant.danger,
          );
        }
    }
  }

  Future<String?> _renameDialog(String current) {
    final TextEditingController controller = TextEditingController(
      text: current,
    );
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(controller: controller, autofocus: true),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
