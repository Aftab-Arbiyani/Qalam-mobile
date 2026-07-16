import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/shared/social/data/social_outbox_store.dart';
import 'package:qalam_mobile/shared/social/domain/value_objects/queued_social_action.dart';

QueuedSocialAction _action(
  SocialCategory category,
  String target, {
  bool desired = true,
  int day = 1,
}) => QueuedSocialAction(
  category: category,
  targetId: target,
  desired: desired,
  createdAt: DateTime.utc(2026, 1, day),
);

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late SocialOutboxStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_outbox');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('prefs_${dir.path.hashCode}');
    store = SocialOutboxStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('put stores an action; readAll returns it', () async {
    await store.put(_action(SocialCategory.pieceLike, 'p1'));
    expect(store.count, 1);
    expect(store.readAll().single.targetId, 'p1');
  });

  test('a later put on the same key overwrites (desired-state collapses)', () async {
    await store.put(_action(SocialCategory.pieceLike, 'p1'));
    await store.put(_action(SocialCategory.pieceLike, 'p1', desired: false, day: 2));
    expect(store.count, 1);
    expect(store.readAll().single.desired, isFalse);
  });

  test('distinct categories/targets coexist; readAll is oldest-first', () async {
    await store.put(_action(SocialCategory.pieceLike, 'p1', day: 2));
    await store.put(_action(SocialCategory.userFollow, 'u1'));
    final List<QueuedSocialAction> all = store.readAll();
    expect(all.length, 2);
    expect(all.first.targetId, 'u1'); // earliest createdAt first
  });

  test('remove drops one by key; clear empties', () async {
    await store.put(_action(SocialCategory.pieceLike, 'p1'));
    await store.put(_action(SocialCategory.pieceBookmark, 'p1'));
    await store.remove(_action(SocialCategory.pieceLike, 'p1').key);
    expect(store.readAll().single.category, SocialCategory.pieceBookmark);
    await store.clear();
    expect(store.count, 0);
  });

  test('survives a reopen (durable JSON)', () async {
    await store.put(_action(SocialCategory.userFollow, 'u9'));
    expect(SocialOutboxStore(box).readAll().single.targetId, 'u9');
  });
}
