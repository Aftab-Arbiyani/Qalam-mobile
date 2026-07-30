/// One conversation's detail controller (AF2, family by id). Loads the full message
/// history and supports **continuation**: `send` streams a new turn through the reused
/// AF1 stream controller (with the conversation id, so the server appends to the same
/// `ai_conversation`), then reloads the history. The live tokens render from
/// [aiStreamControllerProvider]; this controller owns the settled, persisted history.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ai_completion.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/value_objects/ai_feature_ids.dart';
import '../providers/ai_providers.dart';
import 'ai_stream_controller.dart';

part 'conversation_detail_controller.g.dart';

@riverpod
class ConversationDetailController extends _$ConversationDetailController {
  String _id = '';

  @override
  Future<AiConversationDetail> build(String conversationId) {
    _id = conversationId;
    return _load();
  }

  Future<AiConversationDetail> _load() async {
    final Result<AiConversationDetail> result =
        await ref.read(aiRepositoryProvider).getConversation(_id);
    return switch (result) {
      Ok<AiConversationDetail>(:final AiConversationDetail value) => value,
      Err<AiConversationDetail>(:final Failure failure) => throw failure,
    };
  }

  /// Send a new turn and stream the reply into this conversation, then reload so the
  /// persisted user + assistant messages appear. Returns false if the stream errored.
  Future<bool> send(String text) async {
    final AiConversationDetail? current = state.asData?.value;
    final String feature = current?.summary.feature ?? AiFeatureIds.playground;
    final AiCompletionRequest request = AiCompletionRequest(
      feature: feature,
      conversationId: _id,
      promptKey: feature == AiFeatureIds.writingAssistant ? 'writing_assistant.freeform' : null,
      messages: <AiMessage>[AiMessage(role: 'user', content: text)],
    );
    ref.read(aiStreamControllerProvider.notifier).reset();
    await ref.read(aiStreamControllerProvider.notifier).start(request);
    final AiStreamState stream = ref.read(aiStreamControllerProvider);
    if (stream.status == AiStreamStatus.done) {
      state = await AsyncValue.guard(_load);
      return true;
    }
    return false;
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(_load);
  }
}
