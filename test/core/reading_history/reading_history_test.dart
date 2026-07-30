import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/reading_history/reading_history_controller.dart';
import 'package:qalam_mobile/core/reading_history/reading_history_entry.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> container() async {
    final ProviderContainer c = await buildTestContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('records a session and surfaces it in the timeline', () async {
    final ProviderContainer c = await container();
    final ReadingHistoryController ctrl = c.read(
      readingHistoryControllerProvider.notifier,
    );

    await ctrl.record(
      pieceId: 'p1',
      title: 'A Ghazal',
      progress: 0.5,
      sessionSeconds: 10,
    );

    final List<ReadingHistoryEntry> list = c.read(
      readingHistoryControllerProvider,
    );
    expect(list, hasLength(1));
    expect(list.first.progress, 0.5);
    expect(list.first.totalReadSeconds, 10);
    expect(
      c.read(readingHistoryControllerProvider.notifier).positionFor('p1'),
      0.5,
    );
  });

  test('re-recording merges: accrues time, advances position', () async {
    final ProviderContainer c = await container();
    final ReadingHistoryController ctrl = c.read(
      readingHistoryControllerProvider.notifier,
    );

    await ctrl.record(
      pieceId: 'p1',
      title: 'A',
      progress: 0.5,
      sessionSeconds: 10,
    );
    await ctrl.record(
      pieceId: 'p1',
      title: 'A',
      progress: 0.7,
      sessionSeconds: 5,
    );

    final ReadingHistoryEntry entry = c
        .read(readingHistoryControllerProvider)
        .single;
    expect(entry.progress, 0.7);
    expect(entry.totalReadSeconds, 15);
  });

  test(
    'continue-reading excludes finished + trivial; recent keeps order',
    () async {
      final ProviderContainer c = await container();
      final ReadingHistoryController ctrl = c.read(
        readingHistoryControllerProvider.notifier,
      );

      await ctrl.record(
        pieceId: 'a',
        title: 'A',
        progress: 0.4,
        at: DateTime.utc(2026, 2, 3),
      );
      await ctrl.record(
        pieceId: 'b',
        title: 'B',
        progress: 0.99,
        completed: true,
        at: DateTime.utc(2026, 2, 4),
      );
      await ctrl.record(
        pieceId: 'c',
        title: 'C',
        progress: 0.01,
        at: DateTime.utc(2026, 2, 5),
      );

      final List<ReadingHistoryEntry> recent = c.read(recentlyReadListProvider);
      expect(recent.map((ReadingHistoryEntry e) => e.pieceId), <String>[
        'c',
        'b',
        'a',
      ]);

      final List<ReadingHistoryEntry> cont = c.read(
        continueReadingListProvider,
      );
      expect(cont.map((ReadingHistoryEntry e) => e.pieceId), <String>['a']);
    },
  );

  test('completed pins progress to 1.0 and sticks', () async {
    final ProviderContainer c = await container();
    final ReadingHistoryController ctrl = c.read(
      readingHistoryControllerProvider.notifier,
    );
    await ctrl.record(
      pieceId: 'p',
      title: 'P',
      progress: 0.96,
      completed: true,
    );
    final ReadingHistoryEntry e = c
        .read(readingHistoryControllerProvider)
        .single;
    expect(e.isCompleted, isTrue);
    expect(e.progress, 1.0);
  });

  test('denormalized card fields persist for offline rendering', () async {
    final ProviderContainer c = await container();
    await c
        .read(readingHistoryControllerProvider.notifier)
        .record(
          pieceId: 'p',
          title: 'Title',
          authorName: 'Farheen',
          coverImageKey: 'k',
          languageCode: 'ur',
          direction: TextDirectionKind.rtl,
          progress: 0.3,
        );
    final ReadingHistoryEntry e = c
        .read(readingHistoryControllerProvider)
        .single;
    expect(e.authorName, 'Farheen');
    expect(e.coverImageKey, 'k');
    expect(e.direction, TextDirectionKind.rtl);
  });

  test('remove and clearAll', () async {
    final ProviderContainer c = await container();
    final ReadingHistoryController ctrl = c.read(
      readingHistoryControllerProvider.notifier,
    );
    await ctrl.record(pieceId: 'a', title: 'A', progress: 0.2);
    await ctrl.record(pieceId: 'b', title: 'B', progress: 0.2);
    await ctrl.remove('a');
    expect(
      c
          .read(readingHistoryControllerProvider)
          .map((ReadingHistoryEntry e) => e.pieceId),
      <String>['b'],
    );
    await ctrl.clearAll();
    expect(c.read(readingHistoryControllerProvider), isEmpty);
  });
}
