/// Recommendations / Discovery (AF4) — server state for a recommendation surface. The
/// backend Recommendation Engine produces every explained item (reason + influencing
/// entities + evidence); the client only renders. Family keyed by (kind, storyId,
/// pieceId) via a record for value-equality caching.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/retrieval.dart';
import '../../domain/value_objects/retrieval_requests.dart';
import '../../domain/value_objects/retrieval_vocab.dart';
import '../providers/ai_providers.dart';

part 'recommendations_controller.g.dart';

typedef RecommendationArgs = ({
  RecommendationKind kind,
  String? storyId,
  String? pieceId,
});

@riverpod
Future<RecommendationResponse> recommendations(
  Ref ref,
  RecommendationArgs args,
) async {
  final Result<RecommendationResponse> result = await ref
      .watch(aiRepositoryProvider)
      .recommendations(
        RecommendationQuery(
          kind: args.kind,
          storyId: args.storyId,
          pieceId: args.pieceId,
        ),
      );
  return switch (result) {
    Ok<RecommendationResponse>(:final RecommendationResponse value) => value,
    Err<RecommendationResponse>(:final Failure failure) => throw failure,
  };
}
