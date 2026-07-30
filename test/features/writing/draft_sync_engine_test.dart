import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/features/writing/data/datasources/draft_local_data_source.dart';
import 'package:qalam_mobile/features/writing/data/sync/draft_sync_engine.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_writing.dart';
import '../../support/harness.dart';

Draft _local(
  String id, {
  DraftIntent intent = DraftIntent.save,
  String language = 'ur',
  String? remoteId,
  DateTime? remoteUpdatedAt,
}) => Draft(
  localId: id,
  remoteId: remoteId,
  title: 'A piece',
  languageCode: language,
  genreSlug: 'ghazal',
  wordCount: 12,
  createdAt: DateTime.utc(2026, 7),
  localUpdatedAt: DateTime.utc(2026, 7, 2),
  remoteUpdatedAt: remoteUpdatedAt,
  syncState: DraftSyncState.pending,
  intent: intent,
);

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late DraftLocalDataSource store;
  late FakePieceEditorRepository repo;
  late DraftSyncEngine engine;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_sync_test');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('drafts_${dir.path.hashCode}');
    store = DraftLocalDataSource(box);
    repo = FakePieceEditorRepository();
    engine = DraftSyncEngine(
      repository: repo,
      store: store,
      connectivity: await buildFakeConnectivity(online: true),
      logger: AppLogger(flavor: AppFlavor.development),
    );
  });

  tearDown(() async {
    engine.dispose();
    await box.close();
    await dir.delete(recursive: true);
  });

  test(
    'creates a local-only draft on the server and marks it synced',
    () async {
      await store.write(_local('a'));
      await engine.syncAll();
      final Draft after = store.read('a')!;
      expect(repo.createCalls, 1);
      expect(after.isRemote, isTrue);
      expect(after.syncState, DraftSyncState.synced);
    },
  );

  test('does not push a draft that has no language yet', () async {
    await store.write(_local('a', language: ''));
    await engine.syncAll();
    expect(repo.createCalls, 0);
    expect(store.read('a')!.syncState, DraftSyncState.pending);
  });

  test('runs a queued publish intent after pushing content', () async {
    await store.write(_local('a', intent: DraftIntent.publish));
    await engine.syncAll();
    expect(repo.publishCalls, 1);
    expect(store.read('a')!.status, PieceStatus.published);
    expect(store.read('a')!.syncState, DraftSyncState.synced);
  });

  test(
    'offline: a transient failure keeps the draft pending (auto-retry)',
    () async {
      repo.offline = true;
      await store.write(_local('a'));
      await engine.syncAll();
      expect(store.read('a')!.syncState, DraftSyncState.pending);
    },
  );

  test('detects a conflict when the server changed since our base', () async {
    repo
      ..serverUpdatedAt = DateTime.utc(2026, 7, 10)
      ..headUpdatedAt = DateTime.utc(2026, 7, 12); // newer than our base
    await store.write(
      _local(
        'a',
        remoteId: 'srv-1',
        remoteUpdatedAt: DateTime.utc(2026, 7, 10),
      ),
    );
    await engine.syncAll();
    expect(store.read('a')!.syncState, DraftSyncState.conflict);
    expect(repo.updateCalls, 0); // never overwrote the server
  });

  test('updates when the server has not moved past our base', () async {
    repo
      ..serverUpdatedAt = DateTime.utc(2026, 7, 10)
      ..headUpdatedAt = DateTime.utc(2026, 7, 10); // same as base
    await store.write(
      _local(
        'a',
        remoteId: 'srv-1',
        remoteUpdatedAt: DateTime.utc(2026, 7, 10),
      ),
    );
    await engine.syncAll();
    expect(repo.updateCalls, 1);
    expect(store.read('a')!.syncState, DraftSyncState.synced);
  });

  test(
    'a queued delete of a remote draft removes it locally on success',
    () async {
      await store.write(
        _local('a', remoteId: 'srv-1', intent: DraftIntent.delete),
      );
      await engine.syncAll();
      expect(repo.deleteCalls, 1);
      expect(store.read('a'), isNull);
    },
  );

  test(
    'a delete of a never-synced draft is removed without a network call',
    () async {
      await store.write(_local('a', intent: DraftIntent.delete));
      await engine.syncDraftById('a');
      expect(repo.deleteCalls, 0);
      expect(store.read('a'), isNull);
    },
  );
}
