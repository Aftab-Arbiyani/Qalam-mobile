/// The reader's "More like this" controller (docs/48 §3.9, W5-2 upgrade) — up to
/// four other pieces to read next, from the best source available to this reader.
///
/// **Two sources, deliberately in this order** (mirrors web's `use-related-pieces.ts`):
///
/// 1. **The AF4 recommender** (`kind=related_stories&pieceId=…`) for a signed-in
///    reader on a build with AI on and `feature.ai.recommendations` enabled. It
///    seeds off the piece alone (tags + title, server-side) and explains each
///    suggestion with a `reason`.
/// 2. **The tag search** otherwise — the ORIGINAL W1 behaviour, keyed by the
///    piece's first tag, and what a signed-out reader still gets (every AF4 route
///    needs auth + `ai.use`, and most reading-page traffic has neither).
///
/// The fallback also catches the recommender coming back empty (nothing of
/// `targetType == 'piece'`) or erroring, so the section degrades to the older,
/// dumber answer instead of disappearing. The two sources are never queried in
/// parallel: [relatedSuggestions] is a SYNCHRONOUS combinator that reads each
/// upstream provider's already-reactive [AsyncValue] (config → session →
/// feature flags → recommendation) via `ref.watch` — the same pattern already
/// proven by `editor_screen.dart` / `formatting_toolbar.dart`'s AI gating — and
/// waits (returns `.loading()`, via [_stillPending]) rather than falling through
/// early whenever one of those is still resolving. Falling through on "not
/// resolved yet" would treat a reader who is a heartbeat from "authenticated" as
/// signed out and fire the tag search for them anyway: a real parallel-query
/// window, not just a display flicker. See [_stillPending] for the one
/// surprising wrinkle in "still resolving": an [AsyncValue] that is retrying
/// after an error is ALSO still `isLoading`.
///
/// Non-critical throughout, exactly as before: from the reader's perspective, no
/// retries — a failure resolves to an empty list (which the widget renders as
/// nothing at all), and the current piece is filtered out of its own results
/// either way — the server already excludes it, but the client checks again
/// defensively, like web does.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/author.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/enums.dart';
import '../../../ai/domain/entities/ai_feature_flag.dart';
import '../../../ai/domain/entities/retrieval.dart';
import '../../../ai/domain/value_objects/ai_feature_ids.dart';
import '../../../ai/domain/value_objects/retrieval_vocab.dart';
import '../../../ai/presentation/controllers/recommendations_controller.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../providers/reading_providers.dart';

part 'related_pieces_controller.g.dart';

typedef RelatedSuggestionsArgs = ({String pieceId, TagRef? tag});
typedef _TagSearchArgs = ({String pieceId, TagRef tag});

/// How many suggestions the section shows (web ships four).
const int kRelatedPiecesMax = 4;

/// A related-piece suggestion, plus — when the AF4 recommender produced it — why
/// (docs/48 §3.9, W5-2). `null` for the tag-search fallback, which cannot explain
/// itself.
class RelatedSuggestion {
  const RelatedSuggestion({required this.piece, this.reason});

  final PieceSummary piece;
  final String? reason;

  factory RelatedSuggestion.fromPieceSummary(PieceSummary piece) =>
      RelatedSuggestion(piece: piece);
}

@riverpod
AsyncValue<List<RelatedSuggestion>> relatedSuggestions(
  Ref ref,
  RelatedSuggestionsArgs args,
) {
  final bool aiOn = ref.watch(appConfigProvider).enableAi;
  if (!aiOn) return _tagSearchOrEmpty(ref, args);

  final AsyncValue<SessionState> session = ref.watch(sessionControllerProvider);
  if (_stillPending(session)) {
    return const AsyncValue<List<RelatedSuggestion>>.loading();
  }
  if (!(session.asData?.value.isAuthenticated ?? false)) {
    return _tagSearchOrEmpty(ref, args);
  }

  final AsyncValue<AiFeatures> features = ref.watch(aiFeaturesProvider);
  if (_stillPending(features)) {
    return const AsyncValue<List<RelatedSuggestion>>.loading();
  }
  if (!(features.asData?.value.isEnabled(AiFeatureIds.recommendations) ??
      false)) {
    return _tagSearchOrEmpty(ref, args);
  }

  final AsyncValue<RecommendationResponse> recommended = ref.watch(
    recommendationsProvider((
      kind: RecommendationKind.relatedStories,
      storyId: null,
      pieceId: args.pieceId,
    )),
  );
  if (_stillPending(recommended)) {
    return const AsyncValue<List<RelatedSuggestion>>.loading();
  }
  final List<RelatedSuggestion> items =
      (recommended.asData?.value.items ?? const <RecommendationItem>[])
          .where((RecommendationItem item) => item.targetType == 'piece')
          .map(_toSuggestion)
          .whereType<RelatedSuggestion>()
          .where((RelatedSuggestion s) => s.piece.id != args.pieceId)
          .take(kRelatedPiecesMax)
          .toList(growable: false);
  // Empty (nothing usable) or errored (`asData` null) both fall through here —
  // the recommender is unusable either way.
  if (items.isNotEmpty) return AsyncValue<List<RelatedSuggestion>>.data(items);
  return _tagSearchOrEmpty(ref, args);
}

/// True only for a genuinely fresh, never-yet-answered load. Riverpod's default
/// retry policy re-attempts a thrown [Failure] (it isn't a Dart [Error], the one
/// type the policy exempts) for up to ~30s of backoff, and represents each retry
/// as `AsyncLoading` that still CARRIES the last error (`.hasError` is true even
/// though `.isLoading` also is). Waiting out that whole backoff before falling
/// back would make a reader watch this section stay empty for half a minute over
/// what should be an immediate degrade — so an attached error, retry or not,
/// counts as "answered, and unusable" here, never as "still pending".
bool _stillPending(AsyncValue<Object?> value) =>
    value.isLoading && !value.hasError;

AsyncValue<List<RelatedSuggestion>> _tagSearchOrEmpty(
  Ref ref,
  RelatedSuggestionsArgs args,
) {
  final TagRef? tag = args.tag;
  if (tag == null || tag.slug.isEmpty) {
    return const AsyncValue<List<RelatedSuggestion>>.data(
      <RelatedSuggestion>[],
    );
  }
  return ref.watch(_tagSearchProvider((pieceId: args.pieceId, tag: tag)));
}

/// The tag search itself — a self-contained `Future` provider with exactly one
/// upstream dependency ([readingRepositoryProvider]). It never rejects (a failed
/// [Result] resolves to an empty list rather than throwing), so it never enters
/// the retrying-`AsyncLoading` state [_stillPending] has to account for.
@riverpod
Future<List<RelatedSuggestion>> _tagSearch(Ref ref, _TagSearchArgs args) async {
  // One extra, so filtering out the current piece still leaves a full section.
  final Result<List<PieceSummary>> result = await ref
      .watch(readingRepositoryProvider)
      .getRelatedPieces(args.tag, limit: kRelatedPiecesMax + 1);
  return switch (result) {
    Ok<List<PieceSummary>>(:final List<PieceSummary> value) =>
      value
          .where((PieceSummary p) => p.id != args.pieceId)
          .take(kRelatedPiecesMax)
          .map(RelatedSuggestion.fromPieceSummary)
          .toList(growable: false),
    // Swallowed on purpose — a suggestion failing is not the reader's problem.
    Err<List<PieceSummary>>() => const <RelatedSuggestion>[],
  };
}

/// A recommendation as the reader section renders it.
///
/// The recommender's `object` is the same search-piece card the backend already
/// returns for feed/discovery, but every field is read defensively rather than
/// forced through [PieceSummary.fromJson]: a malformed or missing field here must
/// degrade the one suggestion, not throw and take the whole section down with it
/// (mirrors web's `toSuggestion()`). An item missing `targetType == 'piece'`'s id
/// entirely is dropped.
RelatedSuggestion? _toSuggestion(RecommendationItem item) {
  final String id = item.id.isNotEmpty ? item.id : item.navigation.ref;
  if (id.isEmpty) return null;

  final Map<String, dynamic> object = item.object;
  final Object? authorRaw = object['author'];
  final Map<String, dynamic> authorJson = authorRaw is Map
      ? Map<String, dynamic>.from(authorRaw)
      : const <String, dynamic>{};
  final Object? languageRaw = object['language'];
  final bool rtl = languageRaw is Map && languageRaw['direction'] == 'rtl';
  final Object? readingTimeRaw = object['readingTimeSeconds'];
  final String? slug = item.navigation.ref.isNotEmpty
      ? item.navigation.ref
      : null;

  return RelatedSuggestion(
    piece: PieceSummary(
      id: id,
      title: item.title,
      author: Author(
        username: authorJson['username'] is String
            ? authorJson['username'] as String
            : '',
        penName: authorJson['penName'] is String
            ? authorJson['penName'] as String?
            : null,
      ),
      language: LanguageRef(
        code: '',
        direction: rtl ? TextDirectionKind.rtl : TextDirectionKind.ltr,
      ),
      slug: slug,
      subtitle: object['subtitle'] is String
          ? object['subtitle'] as String?
          : null,
      readingTimeSeconds: readingTimeRaw is num ? readingTimeRaw.toInt() : 0,
    ),
    reason: item.reason,
  );
}
