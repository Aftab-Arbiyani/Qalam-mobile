/// The clap outbox handler (M7-3) — and specifically the one behaviour that
/// separates it from every other queued engagement action.
///
/// `SocialSyncHandler.merge` returns `incoming` (`social_sync_handler.dart:78`).
/// For a desired-state toggle that is correct: a later intent supersedes an
/// earlier one. For an accumulating count it is **silent data loss**, and the
/// first test below is written to FAIL against it — see the assertion's own note.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/sync/sync_handler.dart';
import 'package:qalam_mobile/core/sync/sync_operation.dart';
import 'package:qalam_mobile/shared/domain/limits.dart';
import 'package:qalam_mobile/shared/social/data/sync/clap_sync_handler.dart';

import '../../support/fake_reading_repository.dart';

void main() {
  late FakeEngagementRepository eng;
  late ClapSyncHandler handler;

  setUp(() {
    eng = FakeEngagementRepository();
    handler = ClapSyncHandler(eng);
  });

  SyncOperation op(int count) =>
      buildClapOperation(targetId: 'p1', count: count);

  group('merge SUMS — latest-wins would lose claps the reader already saw', () {
    test('two queued bursts merge to their total, not to the later one', () {
      final SyncOperation existing = op(10);
      final SyncOperation incoming = op(5);

      final SyncOperation? merged = handler.merge(incoming, existing);

      // THIS is the assertion that fails against `=> incoming`. Latest-wins
      // yields 5: the reader queued ten claps offline, tapped five more, and the
      // first ten are thrown away — after the UI already showed all fifteen.
      expect(clapCountOf(merged!), 15);
      expect(
        clapCountOf(merged),
        isNot(clapCountOf(incoming)),
        reason:
            'a latest-wins merge would pass the line above only by accident',
      );
    });

    test('three merges in a row keep accumulating', () {
      SyncOperation acc = op(3);
      for (final int n in <int>[4, 5]) {
        acc = handler.merge(op(n), acc)!;
      }
      expect(clapCountOf(acc), 12);
    });

    test('the sum is clamped to the cap the server would enforce anyway', () {
      final SyncOperation merged = handler.merge(op(40), op(40))!;
      expect(clapCountOf(merged), Limits.maxClapsPerUserPerPiece);
    });

    test(
      'the merged op keeps the EXISTING queue identity and retry record',
      () {
        final SyncOperation existing = op(2).copyWith(
          attempts: 3,
          nextAttemptAt: DateTime(2026, 8, 17, 12),
          lastError: 'boom',
        );
        final SyncOperation incoming = op(1);

        final SyncOperation merged = handler.merge(incoming, existing)!;

        expect(merged.id, existing.id, reason: 'not the newer op\'s id');
        expect(
          merged.createdAt,
          existing.createdAt,
          reason: 'queue ordering held',
        );
        expect(
          merged.attempts,
          3,
          reason: 'tapping again must not hand a failing burst a fresh budget',
        );
        expect(merged.nextAttemptAt, existing.nextAttemptAt);
        expect(clapCountOf(merged), 3);
      },
    );
  });

  group('reconcile', () {
    test('replays the accumulated count through the same repository', () async {
      final SyncOutcome outcome = await handler.reconcile(op(7));

      expect(outcome, isA<SyncSuccess>());
      expect(eng.clapCalls, <int>[7]);
      expect(eng.viewerClaps, 7);
    });

    test(
      'a merged-to-nothing op succeeds without spending a request',
      () async {
        final SyncOutcome outcome = await handler.reconcile(op(0));

        expect(outcome, isA<SyncSuccess>());
        expect(eng.clapCalls, isEmpty);
      },
    );

    test(
      'a transport failure is transient, so the engine retries it',
      () async {
        eng.nextFails = true;
        final SyncOutcome outcome = await handler.reconcile(op(2));

        expect(outcome, isA<SyncTransient>());
      },
    );

    test('the op type is stable — a queued burst survives a restart', () {
      expect(handler.type, 'social.piece_clap');
      expect(op(1).dedupKey, 'p1', reason: 'deduped per piece');
    });
  });
}
