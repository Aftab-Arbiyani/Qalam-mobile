/// Retrieval request value objects — what the client sends to the Retrieval Platform
/// endpoints (docs 36). `toJson`/`toQuery` omit nulls, which is not merely tidy:
/// `forbidNonWhitelisted` is live server-side, so a property the DTO has stopped
/// accepting is a 400, never a no-op.
///
/// **D5** removed `AskBookRequest` with Ask My Book (B2 deleted the route) and
/// `synthesize` with the "AI answer" (B1 removed the synthesis step). Both are off the
/// wire entirely now — the vocabulary contract deleted them from the DTOs once every
/// client had stopped sending them, which is the only safe order given the note above.
library;

import '../../../core/utils/typedefs.dart';
import 'retrieval_vocab.dart';

/// `POST /ai/search`.
class SemanticSearchRequest {
  const SemanticSearchRequest({
    required this.query,
    this.storyId,
    this.queryType,
    this.limit,
    this.language,
    this.genre,
    this.tags,
  });

  final String query;
  final String? storyId;
  final String? queryType;
  final int? limit;
  final String? language;
  final String? genre;
  final List<String>? tags;

  Json toJson() => <String, dynamic>{
    'query': query,
    if (storyId != null) 'storyId': storyId,
    if (queryType != null) 'queryType': queryType,
    if (limit != null) 'limit': limit,
    if (language != null) 'language': language,
    if (genre != null) 'genre': genre,
    if (tags != null && tags!.isNotEmpty) 'tags': tags!.join(','),
  };
}

/// `GET /ai/recommendations` query.
class RecommendationQuery {
  const RecommendationQuery({
    required this.kind,
    this.storyId,
    this.pieceId,
    this.limit,
  });

  final RecommendationKind kind;
  final String? storyId;
  final String? pieceId;
  final int? limit;

  Json toQuery() => <String, dynamic>{
    'kind': kind.wire,
    if (storyId != null) 'storyId': storyId,
    if (pieceId != null) 'pieceId': pieceId,
    if (limit != null) 'limit': limit,
  };
}
