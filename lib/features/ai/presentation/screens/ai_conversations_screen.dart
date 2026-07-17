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
  ConsumerState<AiConversationsScreen> createState() => _AiConversationsScreenState();
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
    final AsyncValue<ConversationsState> async = ref.watch(conversationsControllerProvider);
    return Scaffold(
      appBar: const QAppBar(title: 'AI conversations'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () => ref.invalidate(conversationsControllerProvider),
        ),
        data: _content,
      ),
    );
  }

  Widget _content(ConversationsState state) {
    final List<AiConversationSummary> rows = _query.isEmpty
        ? state.ordered
        : state.ordered
            .where((AiConversationSummary c) =>
                c.displayTitle.toLowerCase().contains(_query.toLowerCase()))
            .toList(growable: false);

    return Column(
      children: <Widget>[
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
              ? const QEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No conversations yet',
                  message: 'Your AI conversations will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(conversationsControllerProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    itemCount: rows.length,
                    itemBuilder: (BuildContext context, int i) =>
                        _row(rows[i], state.isPinned(rows[i].id)),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _row(AiConversationSummary c, bool pinned) {
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
          PopupMenuItem<String>(value: 'pin', child: Text(pinned ? 'Unpin' : 'Pin')),
          const PopupMenuItem<String>(value: 'rename', child: Text('Rename')),
          const PopupMenuItem<String>(value: 'archive', child: Text('Archive')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => unawaited(context.push(Routes.aiConversationPath(c.id))),
    );
  }

  Future<void> _onAction(String action, AiConversationSummary c) async {
    final ConversationsController notifier =
        ref.read(conversationsControllerProvider.notifier);
    switch (action) {
      case 'pin':
        await notifier.togglePin(c.id);
      case 'rename':
        final String? title = await _renameDialog(c.displayTitle);
        if (title != null && title.trim().isNotEmpty) {
          final bool ok = await notifier.rename(c.id, title.trim());
          if (mounted && !ok) {
            QSnackbar.show(context, message: 'Rename failed.', variant: QSnackbarVariant.danger);
          }
        }
      case 'archive':
        await notifier.archive(c.id);
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
    final TextEditingController controller = TextEditingController(text: current);
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
