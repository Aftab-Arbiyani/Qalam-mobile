/// AF4 request value objects — what the client sends to the Retrieval Platform
/// endpoints (docs 36). `toJson`/`toQuery` omit nulls (the backend rejects unknown/
/// null params). No prompt text or business logic lives here.
library;

import '../../../../core/utils/typedefs.dart';
import 'retrieval_vocab.dart';

/// `POST /ai/search`.
class SemanticSearchRequest {
  const SemanticSearchRequest({
    required this.query,
    this.storyId,
    this.queryType,
    this.limit,
    this.synthesize,
    this.language,
    this.genre,
    this.tags,
  });

  final String query;
  final String? storyId;
  final String? queryType;
  final int? limit;
  final bool? synthesize;
  final String? language;
  final String? genre;
  final List<String>? tags;

  Json toJson() => <String, dynamic>{
    'query': query,
    if (storyId != null) 'storyId': storyId,
    if (queryType != null) 'queryType': queryType,
    if (limit != null) 'limit': limit,
    if (synthesize != null) 'synthesize': synthesize,
    if (language != null) 'language': language,
    if (genre != null) 'genre': genre,
    if (tags != null && tags!.isNotEmpty) 'tags': tags!.join(','),
  };
}

/// `POST /ai/ask` and `POST /ai/ask/stream`.
class AskBookRequest {
  const AskBookRequest({
    required this.storyId,
    required this.question,
    this.scope = AskScope.book,
    this.subject,
    this.conversationId,
  });

  final String storyId;
  final String question;
  final AskScope scope;
  final String? subject;
  final String? conversationId;

  Json toJson() => <String, dynamic>{
    'storyId': storyId,
    'question': question,
    'scope': scope.wire,
    if (subject != null && subject!.isNotEmpty) 'subject': subject,
    if (conversationId != null) 'conversationId': conversationId,
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
