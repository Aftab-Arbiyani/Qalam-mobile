/// The Craft Coach controller (AF2). Runs a coaching tool through the SAME reused
/// AF1 orchestrator (a buffered `POST /ai/completions`, feature `craft_coach`), then
/// parses the model's structured JSON into a [CoachReport] with the one shared parser.
/// Coaching NEVER modifies the document — it only reports. Global autoDispose.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_stream_event.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../../domain/value_objects/ai_writing_context.dart';
import '../../domain/value_objects/coach_report.dart';
import '../../domain/value_objects/coach_tool.dart';
import '../providers/ai_providers.dart';

part 'craft_coach_controller.g.dart';

/// Coach reviews can be long; ask for room so the JSON isn't truncated (clamped
/// server-side to the model cap and org bounds).
const int _coachMaxTokens = 2048;

enum CoachPhase { idle, loading, ready, rawOnly, error }

class CraftCoachState {
  const CraftCoachState({
    this.phase = CoachPhase.idle,
    this.tool,
    this.report,
    this.rawText,
    this.usage,
    this.estimatedCostUsd = 0,
    this.provider = '',
    this.model = '',
    this.errorCode,
  });

  final CoachPhase phase;
  final CraftCoachTool? tool;

  /// The parsed report (present when [phase] is ready).
  final CoachReport? report;

  /// Raw model text shown when the JSON couldn't be parsed ([phase] rawOnly).
  final String? rawText;

  final AiTokenUsage? usage;
  final double estimatedCostUsd;
  final String provider;
  final String model;
  final String? errorCode;

  bool get isBusy => phase == CoachPhase.loading;
}

@riverpod
class CraftCoachController extends _$CraftCoachController {
  CraftCoachTool? _lastTool;
  AiWritingContext? _lastContext;

  @override
  CraftCoachState build() => const CraftCoachState();

  /// Run [tool] over [context] (the whole chapter, or a selection for scene work).
  Future<void> run(CraftCoachTool tool, AiWritingContext context) async {
    _lastTool = tool;
    _lastContext = context;

    if (!context.hasOperand) {
      state = CraftCoachState(phase: CoachPhase.error, tool: tool, errorCode: 'AI_EMPTY_INPUT');
      return;
    }

    state = CraftCoachState(phase: CoachPhase.loading, tool: tool);

    final AiCompletionRequest request = AiCompletionRequest(
      feature: AiFeatureIds.craftCoach,
      promptKey: tool.promptKey,
      messages: <AiMessage>[AiMessage(role: 'user', content: context.operand)],
      context: context.contextRequests(),
      params: const <String, dynamic>{'maxTokens': _coachMaxTokens},
    );

    final Result<AiCompletionResult> result =
        await ref.read(aiRepositoryProvider).complete(request);

    switch (result) {
      case Ok<AiCompletionResult>(:final AiCompletionResult value):
        final CoachReport? report = CoachReport.tryParse(value.content);
        state = CraftCoachState(
          phase: report == null ? CoachPhase.rawOnly : CoachPhase.ready,
          tool: tool,
          report: report,
          rawText: report == null ? value.content : null,
          usage: value.usage,
          estimatedCostUsd: value.estimatedCostUsd,
          provider: value.provider,
          model: value.model,
        );
      case Err<AiCompletionResult>(:final Failure failure):
        state = CraftCoachState(
          phase: CoachPhase.error,
          tool: tool,
          errorCode: _codeOf(failure),
        );
    }
  }

  /// Re-run the last tool (Retry / Regenerate).
  Future<void> retry() async {
    final CraftCoachTool? tool = _lastTool;
    final AiWritingContext? context = _lastContext;
    if (tool == null || context == null) return;
    await run(tool, context);
  }

  void reset() => state = const CraftCoachState();

  /// Extract the stable error code from any [Failure] variant (freezed 3 sealed
  /// switch — every case carries a `code`).
  String _codeOf(Failure failure) => switch (failure) {
        NetworkFailure(:final String code) => code,
        AuthFailure(:final String code) => code,
        PermissionFailure(:final String code) => code,
        NotFoundFailure(:final String code) => code,
        ValidationFailure(:final String code) => code,
        ConflictFailure(:final String code) => code,
        DomainRuleFailure(:final String code) => code,
        RateLimitFailure(:final String code) => code,
        UnexpectedFailure(:final String code) => code,
      };
}
