/// The reusable **AI Suggestion** model (AF2) — the heart of the "AI proposes, the
/// editor disposes" contract. A suggestion is NOT editor content: it is a transient,
/// immutable record of one generation (source feature, prompt used, context snapshot,
/// suggested content, diff metadata, provider/model/token usage, timestamp). It stays
/// immutable after generation; accepting it turns it into editor content through the
/// editor's own commands, and rejecting it leaves the document untouched. The same
/// model backs both the Writing Assistant and any future feature that proposes text.
library;

import '../../../../core/utils/typedefs.dart';
import 'ai_stream_event.dart';

/// Lifecycle of a suggestion in the UI.
enum AiSuggestionStatus { streaming, ready, applied, discarded, error }

/// How an accepted suggestion is written into the document (each maps to an existing
/// generic editor command — no AI-specific mutation).
enum AiSuggestionPlacement { replaceSelection, insertBelow, append }

/// A single word-level diff segment between the original operand and the suggestion.
enum DiffKind { equal, added, removed }

class DiffSegment {
  const DiffSegment(this.kind, this.text);
  final DiffKind kind;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is DiffSegment && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);
}

/// Diff metadata for a suggestion — a word-level LCS diff of `original` → `suggested`,
/// powering the Compare view and the added/removed counts. Pure + bounded (operands
/// are a selection or a chapter), so it is safe to compute lazily per render.
class SuggestionDiff {
  const SuggestionDiff({
    required this.original,
    required this.suggested,
    required this.segments,
  });

  final String original;
  final String suggested;
  final List<DiffSegment> segments;

  int get addedWords =>
      segments.where((DiffSegment s) => s.kind == DiffKind.added).length;
  int get removedWords =>
      segments.where((DiffSegment s) => s.kind == DiffKind.removed).length;
  bool get isNoChange => addedWords == 0 && removedWords == 0;

  factory SuggestionDiff.compute(String original, String suggested) {
    final List<String> a = _tokenize(original);
    final List<String> b = _tokenize(suggested);
    // LCS table (rows = a, cols = b). Operands are short (a paragraph/chapter), so
    // O(n·m) is fine; this mirrors the classic diff reconstruction.
    final int n = a.length;
    final int m = b.length;
    final List<List<int>> lcs = List<List<int>>.generate(
      n + 1,
      (_) => List<int>.filled(m + 1, 0),
      growable: false,
    );
    for (int i = n - 1; i >= 0; i--) {
      for (int j = m - 1; j >= 0; j--) {
        lcs[i][j] =
            a[i] == b[j] ? lcs[i + 1][j + 1] + 1 : (lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
      }
    }
    final List<DiffSegment> out = <DiffSegment>[];
    int i = 0;
    int j = 0;
    while (i < n && j < m) {
      if (a[i] == b[j]) {
        out.add(DiffSegment(DiffKind.equal, a[i]));
        i++;
        j++;
      } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
        out.add(DiffSegment(DiffKind.removed, a[i]));
        i++;
      } else {
        out.add(DiffSegment(DiffKind.added, b[j]));
        j++;
      }
    }
    while (i < n) {
      out.add(DiffSegment(DiffKind.removed, a[i]));
      i++;
    }
    while (j < m) {
      out.add(DiffSegment(DiffKind.added, b[j]));
      j++;
    }
    return SuggestionDiff(original: original, suggested: suggested, segments: out);
  }

  /// Whitespace-run tokenization that keeps the trailing space with each token, so
  /// re-joining segments reproduces the text closely enough for a readable diff.
  static List<String> _tokenize(String text) {
    if (text.trim().isEmpty) return const <String>[];
    return text.trim().split(RegExp(r'\s+')).where((String t) => t.isNotEmpty).toList();
  }
}

class AiSuggestion {
  const AiSuggestion({
    required this.id,
    required this.sourceFeature,
    required this.sourceLabel,
    required this.content,
    required this.originalText,
    required this.placement,
    required this.createdAt,
    required this.status,
    this.promptKey,
    this.contextSnapshot = const <String, dynamic>{},
    this.provider = '',
    this.model = '',
    this.usage,
    this.estimatedCostUsd = 0,
    this.finishReason = 'stop',
  });

  /// A unique, human-meaningful id.
  final String id;

  /// The feature that produced it (`AiFeatureIds.*`).
  final String sourceFeature;

  /// The human action label ("Rewrite", "Improve clarity", "Casual tone").
  final String sourceLabel;

  /// The server prompt template used (its BODY lives only on the server).
  final String? promptKey;

  /// A snapshot of the context sent (action/aspect/tone, whether a selection was
  /// used, which metadata keys were included) — for audit + the "why" disclosure.
  final Json contextSnapshot;

  /// The suggested content (immutable once generated).
  final String content;

  /// The operand the suggestion was derived from — the diff/compare baseline and
  /// the reference an "Undo AI application" restores toward.
  final String originalText;

  /// The default placement for a one-click Apply.
  final AiSuggestionPlacement placement;

  final DateTime createdAt;
  final String provider;
  final String model;
  final AiTokenUsage? usage;
  final double estimatedCostUsd;
  final String finishReason;
  final AiSuggestionStatus status;

  bool get hasContent => content.trim().isNotEmpty;

  /// Lazily computed diff metadata (word-level).
  SuggestionDiff get diff => SuggestionDiff.compute(originalText, content);

  /// Status-only transition (content stays immutable — a new instance is returned).
  AiSuggestion withStatus(AiSuggestionStatus next) => AiSuggestion(
        id: id,
        sourceFeature: sourceFeature,
        sourceLabel: sourceLabel,
        content: content,
        originalText: originalText,
        placement: placement,
        createdAt: createdAt,
        status: next,
        promptKey: promptKey,
        contextSnapshot: contextSnapshot,
        provider: provider,
        model: model,
        usage: usage,
        estimatedCostUsd: estimatedCostUsd,
        finishReason: finishReason,
      );
}
