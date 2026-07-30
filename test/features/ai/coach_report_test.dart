import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/coach_report.dart';

void main() {
  group('CoachReport.tryParse', () {
    test('parses a clean JSON object', () {
      const String raw =
          '{"score": 82, "summary": "Strong voice.", "strengths": ["Vivid imagery"], '
          '"weaknesses": ["Slow open"], "suggestions": ["Cut the first line"], '
          '"recommendations": ["Read it aloud"], '
          '"sections": [{"title": "Voice", "detail": "Distinct and consistent."}]}';
      final CoachReport? report = CoachReport.tryParse(raw);
      expect(report, isNotNull);
      expect(report!.score, 82);
      expect(report.summary, 'Strong voice.');
      expect(report.strengths, <String>['Vivid imagery']);
      expect(report.weaknesses, <String>['Slow open']);
      expect(report.suggestions, <String>['Cut the first line']);
      expect(report.recommendations, <String>['Read it aloud']);
      expect(report.sections.single.title, 'Voice');
    });

    test('recovers JSON wrapped in code fences and prose', () {
      const String raw = 'Here is your review:\n```json\n{"score": 50, "summary": "Fine."}\n```\nHope it helps!';
      final CoachReport? report = CoachReport.tryParse(raw);
      expect(report, isNotNull);
      expect(report!.score, 50);
      expect(report.summary, 'Fine.');
    });

    test('clamps the score to 0–100', () {
      expect(CoachReport.tryParse('{"score": 240, "summary": "x"}')!.score, 100);
      expect(CoachReport.tryParse('{"score": -5, "summary": "x"}')!.score, 0);
    });

    test('tolerates missing arrays (defaults to empty)', () {
      final CoachReport report = CoachReport.tryParse('{"score": 60, "summary": "ok"}')!;
      expect(report.strengths, isEmpty);
      expect(report.sections, isEmpty);
    });

    test('returns null when no JSON object is present', () {
      expect(CoachReport.tryParse('the model refused to answer'), isNull);
      expect(CoachReport.tryParse(''), isNull);
    });
  });
}
