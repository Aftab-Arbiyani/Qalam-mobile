/// The parsed Craft Coach report (AF2) — the client's ONE parser for every coach
/// tool's structured JSON output (score, summary, strengths, weaknesses, suggestions,
/// recommendations, sections). Parsing is defensive: coach prompts instruct plain JSON
/// (no reliance on provider JSON-mode), so [CoachReport.tryParse] tolerates code
/// fences and stray prose and returns null only when nothing usable is found (the UI
/// then falls back to the raw text). Pure Dart.
library;

import 'dart:convert';

import '../../../../core/utils/typedefs.dart';

/// One titled section of the analysis (a beat, an aspect, a detected issue).
class CoachSection {
  const CoachSection({required this.title, required this.detail});
  final String title;
  final String detail;
}

class CoachReport {
  const CoachReport({
    required this.score,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    required this.recommendations,
    required this.sections,
  });

  /// Overall craft rating for this review, 0–100 (clamped).
  final int score;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;
  final List<String> recommendations;
  final List<CoachSection> sections;

  bool get isEmpty =>
      summary.isEmpty &&
      strengths.isEmpty &&
      weaknesses.isEmpty &&
      suggestions.isEmpty &&
      recommendations.isEmpty &&
      sections.isEmpty;

  /// Parse a model response into a report. Returns null when no JSON object can be
  /// recovered — callers show [rawFallback] instead.
  static CoachReport? tryParse(String raw) {
    final String? jsonText = _extractJsonObject(raw);
    if (jsonText == null) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    final Json map = Json.from(decoded);
    final CoachReport report = CoachReport(
      score: _clampScore(map['score']),
      summary: _string(map['summary']),
      strengths: _stringList(map['strengths']),
      weaknesses: _stringList(map['weaknesses']),
      suggestions: _stringList(map['suggestions']),
      recommendations: _stringList(map['recommendations']),
      sections: _sections(map['sections']),
    );
    return report.isEmpty ? null : report;
  }

  /// Find the outermost `{ … }` in [raw], stripping ``` fences / prose around it.
  static String? _extractJsonObject(String raw) {
    final int start = raw.indexOf('{');
    final int end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    return raw.substring(start, end + 1);
  }

  static int _clampScore(Object? value) {
    final num n = value is num ? value : (num.tryParse('${value ?? ''}') ?? 0);
    return n.round().clamp(0, 100);
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((Object? e) => e is String ? e.trim() : '${e ?? ''}'.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static List<CoachSection> _sections(Object? value) {
    if (value is! List) return const <CoachSection>[];
    final List<CoachSection> out = <CoachSection>[];
    for (final Object? item in value) {
      if (item is! Map) continue;
      final String title = _string(item['title']);
      final String detail = _string(item['detail']);
      if (title.isEmpty && detail.isEmpty) continue;
      out.add(CoachSection(title: title.isEmpty ? 'Note' : title, detail: detail));
    }
    return out;
  }
}
