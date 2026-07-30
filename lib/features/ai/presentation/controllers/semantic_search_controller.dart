/// Semantic Search (AF4) — the retrieval SESSION (client UI state: query, story scope,
/// synthesis toggle, submitted flag) plus the server-state providers for results and
/// suggestions. The client only holds query state + renders; the backend Retrieval
/// Platform owns intent/classification/planning/ranking/retrieval.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/retrieval.dart';
import '../../domain/value_objects/retrieval_requests.dart';
import '../providers/ai_providers.dart';
import 'ai_search_history_controller.dart';

part 'semantic_search_controller.g.dart';

/// Family args for a semantic-search request (records give value equality = cache key).
typedef SemanticSearchArgs = ({String query, String? storyId, bool synthesize});

/// Family args for suggestions.
typedef SuggestionArgs = ({String prefix, String? storyId});

/// The active retrieval session — the client-side query state (docs 40 §8: URL/UI state,
/// never a mirror of server state).
class RetrievalSession {
  const RetrievalSession({
    this.query = '',
    this.storyId,
    this.synthesize = false,
    this.submitted = false,
  });

  final String query;
  final String? storyId;
  final bool synthesize;
  final bool submitted;

  bool get canSubmit => query.trim().length >= 2;

  SemanticSearchArgs get args =>
      (query: query.trim(), storyId: storyId, synthesize: synthesize);

  RetrievalSession copyWith({
    String? query,
    String? storyId,
    bool clearStory = false,
    bool? synthesize,
    bool? submitted,
  }) => RetrievalSession(
    query: query ?? this.query,
    storyId: clearStory ? null : (storyId ?? this.storyId),
    synthesize: synthesize ?? this.synthesize,
    submitted: submitted ?? this.submitted,
  );
}

@riverpod
class RetrievalSessionController extends _$RetrievalSessionController {
  @override
  RetrievalSession build() => const RetrievalSession();

  void setStory(String? storyId) => state = state.copyWith(
    storyId: storyId,
    clearStory: storyId == null,
    submitted: false,
  );

  void onQueryChanged(String query) =>
      state = state.copyWith(query: query, submitted: false);

  /// Toggle grounded-answer synthesis, keeping the submitted state so results refresh.
  void toggleSynthesize() =>
      state = state.copyWith(synthesize: !state.synthesize);

  /// Commit the query (records it to history). Returns false if too short.
  bool submit([String? query]) {
    if (query != null) state = state.copyWith(query: query);
    if (!state.canSubmit) return false;
    state = state.copyWith(submitted: true);
    unawaited(
      ref
          .read(aiSearchHistoryControllerProvider.notifier)
          .record(state.query.trim()),
    );
    return true;
  }

  void clear() => state = const RetrievalSession();
}

/// Server state: ranked, grounded, explainable results for a submitted query.
@riverpod
Future<SemanticSearchResponse> semanticSearchResults(
  Ref ref,
  SemanticSearchArgs args,
) async {
  final Result<SemanticSearchResponse> result = await ref
      .watch(aiRepositoryProvider)
      .searchSemantic(
        SemanticSearchRequest(
          query: args.query,
          storyId: args.storyId,
          synthesize: args.synthesize ? true : null,
        ),
      );
  return switch (result) {
    Ok<SemanticSearchResponse>(:final SemanticSearchResponse value) => value,
    Err<SemanticSearchResponse>(:final Failure failure) => throw failure,
  };
}

/// Server state: debounced query suggestions (empty for short prefixes; never errors).
@riverpod
Future<List<String>> searchSuggestions(Ref ref, SuggestionArgs args) async {
  if (args.prefix.trim().length < 2) return const <String>[];
  final Result<List<String>> result = await ref
      .watch(aiRepositoryProvider)
      .searchSuggestions(args.prefix, storyId: args.storyId);
  return switch (result) {
    Ok<List<String>>(:final List<String> value) => value,
    Err<List<String>>() => const <String>[],
  };
}
