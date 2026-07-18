/// AF4 retrieval domain entities — the grounded, explainable shapes the backend
/// Retrieval Platform returns (docs 36). Plain immutable value types with `fromJson`
/// (matching the AI feature's style). The client RENDERS these; it never re-derives
/// ranking, retrieval, or recommendation logic (the backend is the source of truth).
library;

import '../../../../core/utils/typedefs.dart';

List<T> _list<T>(Object? raw, T Function(Json) fromJson) {
  if (raw is! List) return const <Never>[];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> e) => fromJson(Json.from(e)))
      .toList(growable: false);
}

double _double(Object? raw) => (raw as num?)?.toDouble() ?? 0;
String _string(Object? raw) => raw is String ? raw : '';

/// A grounding reference — where a result came from + the supporting text.
class RetrievalEvidence {
  const RetrievalEvidence({
    required this.source,
    required this.ref,
    required this.label,
    required this.quote,
    required this.score,
  });

  final String source;
  final String ref;
  final String label;
  final String quote;
  final double score;

  factory RetrievalEvidence.fromJson(Json json) => RetrievalEvidence(
    source: _string(json['source']),
    ref: _string(json['ref']),
    label: _string(json['label']),
    quote: _string(json['quote']),
    score: _double(json['score']),
  );
}

/// An entity related to a result (a graph neighbour, shared tag, same author…).
class RelatedEntity {
  const RelatedEntity({
    required this.id,
    required this.type,
    required this.name,
    required this.relation,
  });

  final String id;
  final String type;
  final String name;
  final String relation;

  factory RelatedEntity.fromJson(Json json) => RelatedEntity(
    id: _string(json['id']),
    type: _string(json['type']),
    name: _string(json['name']),
    relation: _string(json['relation']),
  );
}

/// Where selecting a result should take the user.
class NavigationTarget {
  const NavigationTarget({required this.kind, required this.ref, this.view});

  final String kind;
  final String ref;
  final String? view;

  factory NavigationTarget.fromJson(Json json) => NavigationTarget(
    kind: _string(json['kind']),
    ref: _string(json['ref']),
    view: json['view'] as String?,
  );
}

/// One contributing signal in a ranking explanation.
class RankingSignalContribution {
  const RankingSignalContribution({
    required this.signal,
    required this.weight,
    required this.value,
    required this.contribution,
  });

  final String signal;
  final double weight;
  final double value;
  final double contribution;

  factory RankingSignalContribution.fromJson(Json json) =>
      RankingSignalContribution(
        signal: _string(json['signal']),
        weight: _double(json['weight']),
        value: _double(json['value']),
        contribution: _double(json['contribution']),
      );
}

/// How a result's final score was computed — the "why this rank" contract.
class RankingExplanation {
  const RankingExplanation({
    required this.score,
    required this.summary,
    required this.signals,
  });

  final double score;
  final String summary;
  final List<RankingSignalContribution> signals;

  factory RankingExplanation.fromJson(Json json) => RankingExplanation(
    score: _double(json['score']),
    summary: _string(json['summary']),
    signals: _list(json['signals'], RankingSignalContribution.fromJson),
  );
}

/// Aggregate metadata attached to every retrieval response.
class RetrievalResponseMeta {
  const RetrievalResponseMeta({
    required this.sources,
    required this.totalCandidates,
    required this.returned,
    required this.confidence,
    required this.degraded,
    this.failureReason,
  });

  final List<String> sources;
  final int totalCandidates;
  final int returned;
  final double confidence;
  final bool degraded;
  final String? failureReason;

  factory RetrievalResponseMeta.fromJson(Json json) => RetrievalResponseMeta(
    sources:
        (json['sources'] as List?)?.whereType<String>().toList() ??
        const <String>[],
    totalCandidates: (json['totalCandidates'] as num?)?.toInt() ?? 0,
    returned: (json['returned'] as num?)?.toInt() ?? 0,
    confidence: _double(json['confidence']),
    degraded: json['degraded'] == true,
    failureReason: json['failureReason'] as String?,
  );
}

/// One ranked, grounded, explainable search result.
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.type,
    required this.sourceType,
    required this.title,
    required this.summary,
    required this.object,
    required this.confidence,
    required this.relevanceScore,
    required this.evidence,
    required this.relatedEntities,
    required this.navigation,
    required this.reason,
    required this.ranking,
  });

  final String id;
  final String type;
  final String sourceType;
  final String title;
  final String summary;

  /// The structured domain object (graph-node fields, or a piece/author card).
  final Json object;
  final double confidence;
  final double relevanceScore;
  final List<RetrievalEvidence> evidence;
  final List<RelatedEntity> relatedEntities;
  final NavigationTarget navigation;
  final String reason;
  final RankingExplanation ranking;

  factory SearchResultItem.fromJson(Json json) => SearchResultItem(
    id: _string(json['id']),
    type: _string(json['type']),
    sourceType: _string(json['sourceType']),
    title: _string(json['title']),
    summary: _string(json['summary']),
    object: json['object'] is Map
        ? Json.from(json['object'] as Map)
        : const <String, dynamic>{},
    confidence: _double(json['confidence']),
    relevanceScore: _double(json['relevanceScore']),
    evidence: _list(json['evidence'], RetrievalEvidence.fromJson),
    relatedEntities: _list(json['relatedEntities'], RelatedEntity.fromJson),
    navigation: json['navigation'] is Map
        ? NavigationTarget.fromJson(Json.from(json['navigation'] as Map))
        : const NavigationTarget(kind: '', ref: ''),
    reason: _string(json['reason']),
    ranking: json['ranking'] is Map
        ? RankingExplanation.fromJson(Json.from(json['ranking'] as Map))
        : const RankingExplanation(
            score: 0,
            summary: '',
            signals: <RankingSignalContribution>[],
          ),
  );
}

/// The full semantic-search response (grounded results + optional synthesised answer).
class SemanticSearchResponse {
  const SemanticSearchResponse({
    required this.query,
    required this.intent,
    required this.queryType,
    required this.answer,
    required this.results,
    required this.evidence,
    required this.meta,
  });

  final String query;
  final String intent;
  final String queryType;
  final String? answer;
  final List<SearchResultItem> results;
  final List<RetrievalEvidence> evidence;
  final RetrievalResponseMeta meta;

  factory SemanticSearchResponse.fromJson(Json json) => SemanticSearchResponse(
    query: _string(json['query']),
    intent: _string(json['intent']),
    queryType: _string(json['queryType']),
    answer: json['answer'] as String?,
    results: _list(json['results'], SearchResultItem.fromJson),
    evidence: _list(json['evidence'], RetrievalEvidence.fromJson),
    meta: json['meta'] is Map
        ? RetrievalResponseMeta.fromJson(Json.from(json['meta'] as Map))
        : const RetrievalResponseMeta(
            sources: <String>[],
            totalCandidates: 0,
            returned: 0,
            confidence: 0,
            degraded: false,
          ),
  );
}

/// One explainable recommendation.
class RecommendationItem {
  const RecommendationItem({
    required this.id,
    required this.kind,
    required this.targetType,
    required this.title,
    required this.summary,
    required this.object,
    required this.score,
    required this.confidence,
    required this.reason,
    required this.influencedBy,
    required this.evidence,
    required this.navigation,
  });

  final String id;
  final String kind;
  final String targetType;
  final String title;
  final String summary;
  final Json object;
  final double score;
  final double confidence;
  final String reason;
  final List<RelatedEntity> influencedBy;
  final List<RetrievalEvidence> evidence;
  final NavigationTarget navigation;

  factory RecommendationItem.fromJson(Json json) => RecommendationItem(
    id: _string(json['id']),
    kind: _string(json['kind']),
    targetType: _string(json['targetType']),
    title: _string(json['title']),
    summary: _string(json['summary']),
    object: json['object'] is Map
        ? Json.from(json['object'] as Map)
        : const <String, dynamic>{},
    score: _double(json['score']),
    confidence: _double(json['confidence']),
    reason: _string(json['reason']),
    influencedBy: _list(json['influencedBy'], RelatedEntity.fromJson),
    evidence: _list(json['evidence'], RetrievalEvidence.fromJson),
    navigation: json['navigation'] is Map
        ? NavigationTarget.fromJson(Json.from(json['navigation'] as Map))
        : const NavigationTarget(kind: '', ref: ''),
  );
}

/// A recommendation surface's results.
class RecommendationResponse {
  const RecommendationResponse({
    required this.kind,
    required this.items,
    required this.meta,
  });

  final String kind;
  final List<RecommendationItem> items;
  final RetrievalResponseMeta meta;

  factory RecommendationResponse.fromJson(Json json) => RecommendationResponse(
    kind: _string(json['kind']),
    items: _list(json['items'], RecommendationItem.fromJson),
    meta: json['meta'] is Map
        ? RetrievalResponseMeta.fromJson(Json.from(json['meta'] as Map))
        : const RetrievalResponseMeta(
            sources: <String>[],
            totalCandidates: 0,
            returned: 0,
            confidence: 0,
            degraded: false,
          ),
  );
}
