import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/growth_series.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/piece_analytics.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/reader_analytics.dart';
import 'package:qalam_mobile/features/analytics/domain/entities/writer_analytics.dart';
import 'package:qalam_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:qalam_mobile/features/analytics/domain/value_objects/analytics_range.dart';
import 'package:qalam_mobile/features/analytics/presentation/controllers/analytics_range_controller.dart';
import 'package:qalam_mobile/features/analytics/presentation/controllers/creator_analytics_controller.dart';
import 'package:qalam_mobile/features/analytics/presentation/providers/analytics_providers.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository({this.writer, this.growth});

  final WriterAnalytics? writer;
  final GrowthSeries? growth;
  String? lastGrowthPeriod;
  int? lastGrowthPoints;

  @override
  Future<Result<WriterAnalytics>> writerAnalytics() async =>
      Ok<WriterAnalytics>(writer ?? WriterAnalytics.empty);

  @override
  Future<Result<GrowthSeries>> writerGrowth({
    required String period,
    required int points,
  }) async {
    lastGrowthPeriod = period;
    lastGrowthPoints = points;
    return Ok<GrowthSeries>(growth ?? GrowthSeries.empty);
  }

  @override
  Future<Result<ReaderAnalytics>> readerAnalytics() async =>
      const Ok<ReaderAnalytics>(ReaderAnalytics.empty);

  @override
  Future<Result<PieceAnalytics>> pieceAnalytics(String pieceId) async =>
      Ok<PieceAnalytics>(PieceAnalytics(pieceId: pieceId));
}

void main() {
  test('writerAnalytics surfaces the repository aggregate', () async {
    final FakeAnalyticsRepository repo = FakeAnalyticsRepository(
      writer: const WriterAnalytics(totalViews: 1234, reads: 200),
    );
    final ProviderContainer c = ProviderContainer(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);

    final WriterAnalytics w = await c.read(writerAnalyticsProvider.future);
    expect(w.totalViews, 1234);
    expect(w.reads, 200);
  });

  test('the range maps onto the growth query and re-fetches on change', () async {
    final FakeAnalyticsRepository repo = FakeAnalyticsRepository();
    final ProviderContainer c = ProviderContainer(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    c.listen(writerGrowthProvider, (_, _) {});

    // Default range is Last 30 days → daily / 30.
    await c.read(writerGrowthProvider.future);
    expect(repo.lastGrowthPeriod, 'daily');
    expect(repo.lastGrowthPoints, 30);

    // Switch to Last 7 days → daily / 7.
    c.read(analyticsRangeControllerProvider.notifier).select(
      AnalyticsRangePreset.last7,
    );
    await c.read(writerGrowthProvider.future);
    expect(repo.lastGrowthPoints, 7);
  });
}
