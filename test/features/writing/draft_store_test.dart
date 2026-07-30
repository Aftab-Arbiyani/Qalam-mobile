import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/features/writing/data/datasources/draft_local_data_source.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_summary.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';

Draft _draft(
  String id, {
  DraftSyncState sync = DraftSyncState.synced,
  DateTime? at,
}) => Draft(
  localId: id,
  title: 'Draft $id',
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: at ?? DateTime.utc(2026, 7, 2),
  syncState: sync,
);

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late DraftLocalDataSource store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_drafts_test');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('drafts_${dir.path.hashCode}');
    store = DraftLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await dir.delete(recursive: true);
  });

  test('write then read round-trips a draft', () async {
    await store.write(_draft('a'));
    final Draft? read = store.read('a');
    expect(read, isNotNull);
    expect(read!.title, 'Draft a');
  });

  test('readByRemoteId finds a synced draft', () async {
    await store.write(_draft('a').copyWith(remoteId: 'srv-1'));
    expect(store.readByRemoteId('srv-1')?.localId, 'a');
  });

  test('all() returns newest-edited first', () async {
    await store.write(_draft('old', at: DateTime.utc(2026, 7)));
    await store.write(_draft('new', at: DateTime.utc(2026, 7, 5)));
    expect(store.all().map((Draft d) => d.localId).toList(), <String>[
      'new',
      'old',
    ]);
  });

  test('pending() returns only dirty drafts, oldest first', () async {
    await store.write(
      _draft('p1', sync: DraftSyncState.pending, at: DateTime.utc(2026, 7)),
    );
    await store.write(_draft('synced'));
    await store.write(
      _draft('p2', sync: DraftSyncState.failed, at: DateTime.utc(2026, 7, 3)),
    );
    expect(store.pending().map((Draft d) => d.localId).toList(), <String>[
      'p1',
      'p2',
    ]);
  });

  test('server summaries cache round-trips', () async {
    await store.writeServerSummaries(<DraftSummary>[
      const DraftSummary(remoteId: 'srv-1', title: 'Server'),
    ]);
    final List<DraftSummary> back = store.serverSummaries();
    expect(back.single.remoteId, 'srv-1');
    expect(back.single.title, 'Server');
  });

  test('unparseable records are skipped, not fatal', () async {
    await box.put('d:corrupt', 'not-json');
    await store.write(_draft('good'));
    expect(store.all().map((Draft d) => d.localId), <String>['good']);
  });
}
