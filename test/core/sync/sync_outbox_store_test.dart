import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/sync/sync_operation.dart';
import 'package:qalam_mobile/core/sync/sync_outbox_store.dart';

SyncOperation makeOp(String type, String key, {DateTime? at}) => SyncOperation(
  id: '$type-$key-${at?.millisecondsSinceEpoch ?? 0}',
  type: type,
  dedupKey: key,
  payload: <String, dynamic>{'k': key},
  createdAt: at ?? DateTime.utc(2026),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Box<dynamic> box;
  late SyncOutboxStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sync_outbox');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('outbox_${dir.path.hashCode}');
    store = SyncOutboxStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('upsert dedups by (type, dedupKey); order follows createdAt', () async {
    await store.upsert(makeOp('social.piece_like', 'p1', at: DateTime.utc(2026)));
    await store.upsert(makeOp('social.piece_like', 'p2', at: DateTime.utc(2026, 1, 2)));
    // Re-upsert p1 keeping its original createdAt → stays first, still collapsed.
    await store.upsert(makeOp('social.piece_like', 'p1', at: DateTime.utc(2026)));

    expect(store.count, 2); // p1 collapsed
    expect(
      store.readAll().map((SyncOperation o) => o.dedupKey).toList(),
      <String>['p1', 'p2'],
    );
  });

  test('the same dedupKey under different types does not collide', () async {
    await store.upsert(makeOp('social.piece_like', 'x'));
    await store.upsert(makeOp('social.piece_bookmark', 'x'));
    expect(store.count, 2);
  });

  test('remove deletes by storage key; survives reload', () async {
    await store.upsert(makeOp('notification.action', 'n1'));
    await store.upsert(makeOp('notification.action', 'n2'));
    await store.remove('notification.action::n1');

    final SyncOutboxStore reloaded = SyncOutboxStore(box);
    expect(reloaded.count, 1);
    expect(reloaded.readAll().single.dedupKey, 'n2');
  });

  test('a corrupt entry is skipped, not fatal', () async {
    await store.upsert(makeOp('social.piece_like', 'good'));
    // Corrupt the raw JSON map by injecting a bad value under a fresh key.
    await box.put('sync_outbox', '{"bad": "not-a-map", "x": {"type":"t"}}');
    expect(store.readAll(), isNotEmpty); // decodes the valid entry, drops the bad
  });
}
