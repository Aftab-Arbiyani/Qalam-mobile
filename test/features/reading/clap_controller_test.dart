/// The clap gesture (M7-3) — the four properties ported from web's `use-claps`,
/// plus the two mobile-only ones the outbox forces.
///
/// Each `test` here maps to one property, named after it, because the point of
/// this file is that a clap behaves differently from every other engagement
/// action on the bar and each difference is deliberate.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/sync/sync_operation.dart';
import 'package:qalam_mobile/core/sync/sync_providers.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/engagement_controller.dart';
import 'package:qalam_mobile/shared/domain/limits.dart';
import 'package:qalam_mobile/shared/social/data/sync/clap_sync_handler.dart';

import '../../support/fake_reading_repository.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, FakeEngagementRepository)> setup(
    PieceEngagement initial, {
    bool online = true,
    int serverViewerClaps = 0,
    int serverTotal = 0,
  }) async {
    final FakeEngagementRepository eng = FakeEngagementRepository()
      ..viewerClaps = serverViewerClaps
      ..clapTotal = serverTotal;
    final ProviderContainer c = await buildTestContainer(
      online: online,
      readingRepository: FakeReadingRepository(engagement: initial),
      engagementRepository: eng,
    );
    addTearDown(c.dispose);
    c.listen(syncEngineProvider, (_, _) {});
    c.listen(engagementControllerProvider('p1'), (_, _) {});
    await c.read(engagementControllerProvider('p1').future);
    return (c, eng);
  }

  PieceEngagement current(ProviderContainer c) =>
      c.read(engagementControllerProvider('p1')).asData!.value;

  EngagementController notifier(ProviderContainer c) =>
      c.read(engagementControllerProvider('p1').notifier);

  group('1 — it accumulates', () {
    test(
      'each tap moves both counts immediately, before any request',
      () async {
        final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
          const PieceEngagement(claps: 40, clapCount: 2),
        );

        notifier(c)
          ..clap()
          ..clap()
          ..clap();

        expect(current(c).clapCount, 5, reason: 'the viewer\'s own count');
        expect(current(c).claps, 43, reason: 'the piece total');
        expect(
          eng.clapCalls,
          isEmpty,
          reason: 'nothing sent yet — still debouncing',
        );

        await notifier(c).flushClaps(); // settle the pending timer
      },
    );
  });

  group('2 — a burst is ONE request', () {
    test('twenty taps produce exactly one POST carrying twenty', () async {
      final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
        const PieceEngagement(claps: 100),
      );

      for (int i = 0; i < 20; i++) {
        notifier(c).clap();
      }
      await notifier(c).flushClaps();

      expect(eng.clapCalls, <int>[20]);
    });

    test(
      'the window is IDLE — a continuing burst keeps deferring the flush',
      () async {
        final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
          const PieceEngagement(),
        );

        // Two taps either side of a wait SHORTER than the window: still one request.
        notifier(c).clap();
        await Future<void>.delayed(EngagementController.clapFlushDelay ~/ 2);
        notifier(c).clap();
        expect(
          eng.clapCalls,
          isEmpty,
          reason: 'the second tap deferred the flush',
        );

        // Now let it go idle for the full window.
        await Future<void>.delayed(
          EngagementController.clapFlushDelay +
              const Duration(milliseconds: 120),
        );
        expect(eng.clapCalls, <int>[2]);
      },
    );

    test(
      'the flush adopts BOTH server numbers, not its own arithmetic',
      () async {
        // The server holds 48, so our 5 is clamped to 2; and the piece total is
        // ahead of ours because other readers clapped while this screen was open.
        final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
          const PieceEngagement(claps: 100, clapCount: 48),
          serverViewerClaps: 48,
          serverTotal: 900,
        );

        for (int i = 0; i < 5; i++) {
          notifier(c).clap();
        }
        await notifier(c).flushClaps();

        expect(eng.clapCalls, <int>[
          2,
        ], reason: 'clamped at the tap, not the wire');
        expect(current(c).clapCount, 50);
        expect(current(c).claps, 902, reason: 'the server total, not our +5');
      },
    );

    test(
      'a failed flush rolls back exactly what it carried, silently',
      () async {
        final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
          const PieceEngagement(claps: 10, clapCount: 1),
        );

        notifier(c)
          ..clap()
          ..clap();
        eng.nextFails = true;
        await notifier(c).flushClaps();

        expect(current(c).clapCount, 1);
        expect(current(c).claps, 10);
      },
    );
  });

  group('3 — it clamps, and a tap at the cap is a NO-OP', () {
    test('a tap at the cap does not increment and never sends', () async {
      final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
        const PieceEngagement(
          claps: 500,
          clapCount: Limits.maxClapsPerUserPerPiece,
        ),
        serverViewerClaps: Limits.maxClapsPerUserPerPiece,
      );

      for (int i = 0; i < 5; i++) {
        notifier(c).clap();
      }
      await notifier(c).flushClaps();

      expect(current(c).clapCount, Limits.maxClapsPerUserPerPiece);
      expect(
        current(c).claps,
        500,
        reason: 'the piece total did not move either',
      );
      expect(
        eng.clapCalls,
        isEmpty,
        reason: 'CLAP_LIMIT_REACHED must never be provoked by hammering',
      );
    });

    test(
      'the cap counts PENDING taps, so a burst from 49 sends 1, not 20',
      () async {
        final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
          const PieceEngagement(claps: 200, clapCount: 49),
          serverViewerClaps: 49,
          serverTotal: 200,
        );

        for (int i = 0; i < 20; i++) {
          notifier(c).clap();
        }
        await notifier(c).flushClaps();

        expect(eng.clapCalls, <int>[1]);
        expect(current(c).clapCount, Limits.maxClapsPerUserPerPiece);
      },
    );
  });

  group('4 — removal is all-or-nothing', () {
    test('removing takes every clap of mine off both counts', () async {
      final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
        const PieceEngagement(claps: 30, clapCount: 7),
        serverViewerClaps: 7,
        serverTotal: 30,
      );

      await notifier(c).removeClaps();

      expect(current(c).clapCount, 0);
      expect(current(c).claps, 23);
      expect(eng.unclapCalls, 1);
    });

    test('removing DROPS a pending burst — it must not resurrect', () async {
      final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
        const PieceEngagement(claps: 30, clapCount: 7),
        serverViewerClaps: 7,
        serverTotal: 30,
      );

      notifier(c)
        ..clap()
        ..clap();
      await notifier(c).removeClaps();
      // Wait past the window the dropped timer would have fired in.
      await Future<void>.delayed(
        EngagementController.clapFlushDelay + const Duration(milliseconds: 120),
      );

      expect(eng.clapCalls, isEmpty, reason: 'the pending burst was abandoned');
      expect(current(c).clapCount, 0);
    });

    test('a failed removal restores the previous state', () async {
      final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
        const PieceEngagement(claps: 30, clapCount: 7),
      );

      eng.nextFails = true;
      await notifier(c).removeClaps();

      expect(current(c).clapCount, 7);
      expect(current(c).claps, 30);
    });
  });

  group(
    '5 — offline, the burst is queued like every other engagement write',
    () {
      test(
        'an offline flush enqueues the total instead of calling the wire',
        () async {
          final (ProviderContainer c, FakeEngagementRepository eng) =
              await setup(const PieceEngagement(claps: 10), online: false);

          for (int i = 0; i < 4; i++) {
            notifier(c).clap();
          }
          await notifier(c).flushClaps();

          expect(eng.clapCalls, isEmpty);
          expect(
            current(c).clapCount,
            4,
            reason: 'optimistic, not rolled back',
          );

          final SyncOperation op = c
              .read(syncOutboxStoreProvider)
              .readAll()
              .single;
          expect(op.type, clapOpType);
          expect(op.dedupKey, 'p1');
          expect(clapCountOf(op), 4);
        },
      );
    },
  );
}
