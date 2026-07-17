/// The AI feature's domain contract (AF1). Presentation depends on this, never on
/// the data layer. Unary calls return `Result<T>`; streaming returns a broadcast-
/// free `Stream<AiStreamEvent>` whose cancellation (subscription cancel) aborts
/// the underlying request — so presentation never touches Dio.
library;

import '../../../../core/utils/result.dart';
import '../entities/ai_completion.dart';
import '../entities/ai_feature_flag.dart';
import '../entities/ai_stream_event.dart';

abstract interface class AiRepository {
  /// Which AI features are enabled for the caller.
  Future<Result<AiFeatures>> features();

  /// A buffered completion.
  Future<Result<AiCompletionResult>> complete(AiCompletionRequest request);

  /// A streamed completion. Cancel by cancelling the subscription.
  Stream<AiStreamEvent> streamCompletion(AiCompletionRequest request);
}
