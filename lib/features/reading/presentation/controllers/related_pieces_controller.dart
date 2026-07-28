/// The reader's "More like this" controller (docs/48 §3.1) — up to four other
/// pieces sharing the piece's FIRST tag. Family keyed by (pieceId, tag) via a
/// record for value-equality caching.
///
/// Non-critical by construction, exactly as on web: it never surfaces an error.
/// A failed or empty load resolves to an empty list, which the widget renders as
/// nothing at all — this section must never cost the reader the piece they came
/// for. The current piece is filtered out of its own suggestions.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/piece_summary.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../providers/reading_providers.dart';

part 'related_pieces_controller.g.dart';

typedef RelatedPiecesArgs = ({String pieceId, TagRef tag});

/// How many suggestions the section shows (web ships four).
const int kRelatedPiecesMax = 4;

@riverpod
Future<List<PieceSummary>> relatedPieces(
  Ref ref,
  RelatedPiecesArgs args,
) async {
  // One extra, so filtering out the current piece still leaves a full section.
  final Result<List<PieceSummary>> result = await ref
      .watch(readingRepositoryProvider)
      .getRelatedPieces(args.tag, limit: kRelatedPiecesMax + 1);

  return switch (result) {
    Ok<List<PieceSummary>>(:final List<PieceSummary> value) =>
      value
          .where((PieceSummary p) => p.id != args.pieceId)
          .take(kRelatedPiecesMax)
          .toList(growable: false),
    // Swallowed on purpose — a suggestion failing is not the reader's problem.
    Err<List<PieceSummary>>() => const <PieceSummary>[],
  };
}
