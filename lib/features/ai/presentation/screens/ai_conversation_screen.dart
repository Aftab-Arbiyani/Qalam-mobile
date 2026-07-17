/// One conversation (AF2) — the full history plus continuation. New turns stream in
/// via the reused AF1 stream controller (appended to the same server conversation),
/// then the persisted history reloads. Export copies a portable JSON document.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../../../shared/theme/q_tokens.dart';
import '../../../../shared/theme/tokens/spacing_tokens.dart';
import '../../../../shared/widgets/app_bar/q_app_bar.dart';
import '../../../../shared/widgets/feedback/q_snackbar.dart';
import '../../../../shared/widgets/states/q_error_view.dart';
import '../../domain/entities/ai_conversation.dart';
import '../controllers/ai_stream_controller.dart';
import '../controllers/conversation_detail_controller.dart';
import '../providers/ai_providers.dart';
import '../widgets/ai_markdown.dart';
import '../widgets/ai_streaming_text.dart';

class AiConversationScreen extends ConsumerStatefulWidget {
  const AiConversationScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<AiConversationScreen> createState() => _AiConversationScreenState();
}

class _AiConversationScreenState extends ConsumerState<AiConversationScreen> {
  final TextEditingController _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AiConversationDetail> async =
        ref.watch(conversationDetailControllerProvider(widget.conversationId));
    final AiStreamState stream = ref.watch(aiStreamControllerProvider);

    return Scaffold(
      appBar: QAppBar(
        title: async.asData?.value.summary.displayTitle ?? 'Conversation',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export',
            onPressed: () => unawaited(_export()),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => QErrorView(
          failure: error is Failure
              ? error
              : Failure.unexpected(code: ErrorCodes.apiUnexpected, message: '$error'),
          onRetry: () =>
              ref.invalidate(conversationDetailControllerProvider(widget.conversationId)),
        ),
        data: (AiConversationDetail detail) => _content(detail, stream),
      ),
    );
  }

  Widget _content(AiConversationDetail detail, AiStreamState stream) {
    final bool streaming = stream.isStreaming;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: QSpacing.pagePadding,
            children: <Widget>[
              for (final AiConversationMessage m in detail.messages) _bubble(m),
              if (streaming) _liveBubble(stream.text),
            ],
          ),
        ),
        _composerBar(streaming),
      ],
    );
  }

  Widget _bubble(AiConversationMessage m) {
    final QTokens tokens = QTokens.of(context);
    final bool user = m.isUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: QSpacing.s2),
        padding: const EdgeInsets.all(QSpacing.s3),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
        decoration: BoxDecoration(
          color: user ? tokens.colors.accentSubtle : tokens.colors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.colors.border),
        ),
        child: user ? Text(m.content) : AiMarkdown(m.content),
      ),
    );
  }

  Widget _liveBubble(String text) {
    final QTokens tokens = QTokens.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: QSpacing.s2),
        padding: const EdgeInsets.all(QSpacing.s3),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
        decoration: BoxDecoration(
          color: tokens.colors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.colors.border),
        ),
        child: text.isEmpty
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: tokens.colors.accent),
              )
            : AiStreamingText(text: text),
      ),
    );
  }

  Widget _composerBar(bool streaming) {
    final QTokens tokens = QTokens.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(QSpacing.s3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _composer,
                enabled: !streaming,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Continue the conversation…',
                  filled: true,
                  fillColor: tokens.colors.bgRaised,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: QSpacing.s2),
            IconButton(
              icon: Icon(Icons.send, color: tokens.colors.accent),
              tooltip: 'Send',
              onPressed: streaming ? null : () => unawaited(_send()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final String text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    final bool ok = await ref
        .read(conversationDetailControllerProvider(widget.conversationId).notifier)
        .send(text);
    if (mounted && !ok) {
      QSnackbar.show(context, message: 'Message failed to send.', variant: QSnackbarVariant.danger);
    }
  }

  Future<void> _export() async {
    final Result<Json> result =
        await ref.read(aiRepositoryProvider).exportConversation(widget.conversationId);
    if (!mounted) return;
    result.fold(
      (Json json) {
        unawaited(Clipboard.setData(ClipboardData(text: jsonEncode(json))));
        QSnackbar.show(context,
            message: 'Conversation copied as JSON.', variant: QSnackbarVariant.success);
      },
      (Failure _) =>
          QSnackbar.show(context, message: 'Export failed.', variant: QSnackbarVariant.danger),
    );
  }
}
