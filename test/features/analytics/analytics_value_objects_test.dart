import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/reading_history/reading_history_entry.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/growth_series.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/reader_analytics.dart';
import 'package:qalam_mobile/features/analytics/domain/value_objects/analytics_range.dart';
import 'package:qalam_mobile/features/analytics/domain/value_objects/reading_insights.dart';
import 'package:qalam_mobile/features/analytics/presentation/analytics_format.dart';

void main() {
  group('AnalyticsRange → growth query', () {
    test('presets map to the documented period + points', () {
      expect(const AnalyticsRange(preset: AnalyticsRangePreset.today).growthPoints, 1);
      expect(const AnalyticsRange(preset: AnalyticsRangePreset.last7).growthPoints, 7);
      expect(const AnalyticsRange(preset: AnalyticsRangePreset.last90).growthPoints, 90);
      expect(
        const AnalyticsRange(preset: AnalyticsRangePreset.lastYear).growthPeriod,
        'monthly',
      );
    });

    test('custom range clamps its day span to the 90-point server bound', () {
      final AnalyticsRange r = AnalyticsRange(
        preset: AnalyticsRangePreset.custom,
        from: DateTime(2026),
        to: DateTime(2026, 12, 31),
      );
      expect(r.growthPoints, kMaxGrowthPoints);
    });
  });

  group('GrowthSeries', () {
    const GrowthSeries series = GrowthSeries(
      points: <GrowthPoint>[
        GrowthPoint(periodStart: '2026-07-01', metrics: <String, num>{'views': 10}),
        GrowthPoint(periodStart: '2026-07-02', metrics: <String, num>{'views': 25}),
        GrowthPoint(periodStart: '2026-07-03', metrics: <String, num>{'views': 40}),
      ],
    );

    test('cumulative reads raw snapshot values', () {
      expect(series.cumulative(GrowthMetric.views), <double>[10, 25, 40]);
    });

    test('deltas diff consecutive points (first keeps its baseline)', () {
      expect(series.deltas(GrowthMetric.views), <double>[10, 15, 15]);
    });

    test('totalGain is last minus first cumulative', () {
      expect(series.totalGain(GrowthMetric.views), 30);
    });

    test('empty series reports empty', () {
      expect(GrowthSeries.empty.isEmpty, isTrue);
    });
  });

  group('analytics formatters', () {
    test('compactNumber abbreviates', () {
      expect(compactNumber(999), '999');
      expect(compactNumber(1200), '1.2K');
      expect(compactNumber(3400000), '3.4M');
    });

    test('readDuration is human', () {
      expect(readDuration(0), '0m');
      expect(readDuration(90), '1m');
      expect(readDuration(3720), '1h 2m');
      expect(readDuration(90000), '1d 1h');
    });

    test('percentLabel rounds a 0..1 rate', () {
      expect(percentLabel(0.734), '73%');
      expect(percentLabel(1.5), '100%');
    });
  });

  group('buildReadingInsights', () {
    ReadingHistoryEntry entry(
      String id, {
      required double progress,
      required bool completed,
      String? lang,
      DateTime? at,
      int seconds = 60,
    }) => ReadingHistoryEntry(
      pieceId: id,
      title: id,
      lastReadAt: at ?? DateTime.utc(2026, 7, 17, 10),
      languageCode: lang,
      progress: progress,
      isCompleted: completed,
      totalReadSeconds: seconds,
    );

    test('continue reading = in-progress entries; weekly buckets by weekday', () {
      final DateTime now = DateTime.utc(2026, 7, 17, 12); // a Friday
      final List<ReadingHistoryEntry> history = <ReadingHistoryEntry>[
        entry('a', progress: 0.5, completed: false, lang: 'en', at: now),
        entry('b', progress: 1.0, completed: true, lang: 'ur', at: now),
        entry('c', progress: 0.01, completed: false, lang: 'en', at: now),
      ];

      final ReadingInsights insights = buildReadingInsights(
        backend: ReaderAnalytics.empty,
        history: history,
        bookmarksCount: 4,
        now: now,
      );

      // 'a' is in-progress; 'b' completed and 'c' barely started are excluded.
      expect(
        insights.continueReading.map((ReadingHistoryEntry e) => e.pieceId),
        <String>['a'],
      );
      expect(insights.bookmarksCount, 4);
      expect(insights.localLanguages, 2); // en, ur
      expect(insights.weeklyActivity.length, 7);
      final WeekdayActivity friday = insights.weeklyActivity[4]; // Mon=0..Fri=4
      expect(friday.pieces, 3);
    });
  });
}
