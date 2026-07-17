/// A configurable in-memory [AiRepository] for AF2 tests. Replays a fixed stream
/// script, returns canned completions/usage/conversations, and records the requests
/// it received so tests can assert what the client sent (feature, promptKey, context).
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/ai/ai.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';

class FakeAiRepository implements AiRepository {
  FakeAiRepository({
    List<AiStreamEvent>? streamEvents,
    AiCompletionResult? completion,
    AiFeatures? features,
    AiUsageSummary? usage,
    List<AiConversationSummary>? conversations,
    AiConversationDetail? detail,
    this.failure,
  })  : streamEvents = streamEvents ?? const <AiStreamEvent>[],
        _completion = completion,
        _features = features,
        _usage = usage,
        _conversations = conversations ?? const <AiConversationSummary>[],
        _detail = detail;

  final List<AiStreamEvent> streamEvents;
  final AiCompletionResult? _completion;
  final AiFeatures? _features;
  final AiUsageSummary? _usage;
  final List<AiConversationSummary> _conversations;
  final AiConversationDetail? _detail;

  /// When set, every call fails with this failure.
  final Failure? failure;

  // Recorded inputs for assertions.
  AiCompletionRequest? lastCompletionRequest;
  AiCompletionRequest? lastStreamRequest;
  final List<String> deletedConversationIds = <String>[];

  @override
  Future<Result<AiFeatures>> features() async => failure != null
      ? Err<AiFeatures>(failure!)
      : Ok<AiFeatures>(
          _features ?? const AiFeatures(aiEnabled: true, features: <AiFeatureFlag>[]),
        );

  @override
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request) async {
    lastCompletionRequest = request;
    if (failure != null) return Err<AiCompletionResult>(failure!);
    return Ok<AiCompletionResult>(
      _completion ??
          const AiCompletionResult(
            content: 'ok',
            provider: 'openai',
            model: 'gpt-4o',
            finishReason: 'stop',
            estimatedCostUsd: 0,
          ),
    );
  }

  @override
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request) async* {
    lastStreamRequest = request;
    for (final AiStreamEvent event in streamEvents) {
      yield event;
    }
  }

  @override
  Future<Result<AiUsageSummary>> usage() async => failure != null
      ? Err<AiUsageSummary>(failure!)
      : Ok<AiUsageSummary>(
          _usage ??
              const AiUsageSummary(
                daily: AiUsageWindow.zero,
                monthly: AiUsageWindow.zero,
                total: AiUsageWindow.zero,
                byFeature: <AiFeatureUsage>[],
              ),
        );

  @override
  Future<Result<CursorPage<AiConversationSummary>>> listConversations({
    String? cursor,
    int? limit,
  }) async =>
      failure != null
          ? Err<CursorPage<AiConversationSummary>>(failure!)
          : Ok<CursorPage<AiConversationSummary>>(
              CursorPage<AiConversationSummary>(
                items: _conversations,
                meta: const CursorMeta(),
              ),
            );

  @override
  Future<Result<AiConversationSummary>> createConversation({
    required String feature,
    String? title,
  }) async =>
      failure != null
          ? Err<AiConversationSummary>(failure!)
          : Ok<AiConversationSummary>(
              AiConversationSummary(
                id: 'c-new',
                title: title,
                feature: feature,
                status: AiConversationStatus.active,
                messageCount: 0,
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            );

  @override
  Future<Result<AiConversationDetail>> getConversation(String id) async {
    if (failure != null) return Err<AiConversationDetail>(failure!);
    final AiConversationDetail? detail = _detail;
    if (detail != null) return Ok<AiConversationDetail>(detail);
    return const Err<AiConversationDetail>(
      Failure.notFound(code: 'AI_CONVERSATION_NOT_FOUND'),
    );
  }

  @override
  Future<Result<AiConversationSummary>> renameConversation(String id, String title) async =>
      failure != null
          ? Err<AiConversationSummary>(failure!)
          : Ok<AiConversationSummary>(
              _conversations
                  .firstWhere((AiConversationSummary c) => c.id == id)
                  .copyWith(title: title),
            );

  @override
  Future<Result<AiConversationSummary>> setConversationStatus(
    String id,
    AiConversationStatus status,
  ) async =>
      failure != null
          ? Err<AiConversationSummary>(failure!)
          : Ok<AiConversationSummary>(
              _conversations
                  .firstWhere((AiConversationSummary c) => c.id == id)
                  .copyWith(status: status),
            );

  @override
  Future<Result<Unit>> deleteConversation(String id) async {
    if (failure != null) return Err<Unit>(failure!);
    deletedConversationIds.add(id);
    return const Ok<Unit>(unit);
  }

  @override
  Future<Result<Json>> exportConversation(String id) async => failure != null
      ? Err<Json>(failure!)
      : Ok<Json>(<String, dynamic>{'id': id, 'messages': <dynamic>[]});
}
