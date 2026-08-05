/// The on-device "Keep history" binding (docs/48 §3.12, W8-1) — the persistence
/// half of passing `conversationId` from the in-editor assistant. Deliberately
/// durable (a real Hive box, not an in-memory fake) since the whole point is that
/// it survives closing the assistant panel and reopening the app, the mobile
/// analogue of web's URL binding surviving a reload.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/features/ai/data/local/prompt_library_store.dart';

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late PromptLibraryStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_ai_history_binding');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('prefs_${dir.path.hashCode}');
    store = PromptLibraryStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('unbound by default', () {
    expect(store.historyBinding('draft-1'), isNull);
  });

  test('binds a draft to a conversation', () async {
    await store.setHistoryBinding('draft-1', 'conv-1');
    expect(store.historyBinding('draft-1'), 'conv-1');
  });

  test('unbinding one draft leaves others untouched', () async {
    await store.setHistoryBinding('draft-1', 'conv-1');
    await store.setHistoryBinding('draft-2', 'conv-2');
    await store.setHistoryBinding('draft-1', null);
    expect(store.historyBinding('draft-1'), isNull);
    expect(store.historyBinding('draft-2'), 'conv-2');
  });

  test('survives a reopen (persisted as JSON)', () async {
    await store.setHistoryBinding('draft-1', 'conv-1');
    final PromptLibraryStore reopened = PromptLibraryStore(box);
    expect(reopened.historyBinding('draft-1'), 'conv-1');
  });
}
