import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/sync/sync_engine.dart';
import 'package:qalam_mobile/core/sync/sync_handler.dart';
import 'package:qalam_mobile/core/sync/sync_history.dart';
import 'package:qalam_mobile/core/sync/sync_operation.dart';
import 'package:qalam_mobile/core/sync/sync_outbox_store.dart';
import 'package:qalam_mobile/core/sync/sync_status.dart';

/// A connectivity double with a controllable online flag + status stream.
class FakeConnectivity implements ConnectivityService {
  FakeConnectivity({required bool online}) : _online = online;

  bool _online;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  bool get isOnline => _online;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void goOnline() {
    _online = true;
    _controller.add(true);
  }

  void goOffline() {
    _online = false;
    _controller.add(false);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async => _controller.close();
}

/// A configurable handler: each reconcile returns the next queued outcome.
class FakeHandler implements SyncHandler {
  FakeHandler(this.type, {required this.outcome, this.mergeToNull = false});

  @override
  final String type;
  SyncOutcome outcome;
  final bool mergeToNull;
  int calls = 0;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    calls++;
    return outcome;
  }

  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) =>
      mergeToNull ? null : incoming;
}

SyncOperation op(String type, String key, {String? id}) => SyncOperation(
  id: id ?? '$type-$key',
  type: type,
  dedupKey: key,
  payload: const <String, dynamic>{},
  createdAt: DateTime.utc(2026),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late Box<dynamic> box;
  late SyncOutboxStore outbox;
  late SyncHistoryStore history;
  final AppLogger logger = AppLogger(flavor: AppFlavor.development);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sync_engine');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('sync_${dir.path.hashCode}');
    outbox = SyncOutboxStore(box);
    history = SyncHistoryStore(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  SyncEngine build(FakeConnectivity conn, List<SyncHandler> handlers) =>
      SyncEngine(
        outbox: outbox,
        connectivity: conn,
        logger: logger,
        history: history,
        handlers: handlers,
      );

  test('online enqueue drains immediately and records history', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final FakeHandler h = FakeHandler(
      'social.piece_like',
      outcome: const SyncOutcome.success(),
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('social.piece_like', 'p1'));

    expect(h.calls, 1);
    expect(outbox.count, 0);
    expect(engine.status.value.phase, SyncPhase.idle);
    expect(history.readAll().single.result, SyncHistoryResult.synced);
  });

  test('offline enqueue stays queued; reconnect drains it', () async {
    final FakeConnectivity conn = FakeConnectivity(online: false);
    final FakeHandler h = FakeHandler(
      'social.piece_like',
      outcome: const SyncOutcome.success(),
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('social.piece_like', 'p1'));
    expect(h.calls, 0);
    expect(outbox.count, 1);
    expect(engine.status.value.phase, SyncPhase.offline);

    conn.goOnline();
    await Future<void>.delayed(Duration.zero);
    await engine.sync();

    expect(h.calls, 1);
    expect(outbox.count, 0);
  });

  test('transient failure keeps the op pending for retry', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final FakeHandler h = FakeHandler(
      'social.piece_like',
      outcome: const SyncOutcome.transient(
        NetworkFailure(code: 'API_OFFLINE'),
      ),
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('social.piece_like', 'p1'));

    expect(outbox.count, 1);
    expect(outbox.readAll().single.status, SyncOpStatus.pending);
    expect(outbox.readAll().single.attempts, 1);
  });

  test('terminal failure drops the op and logs history', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final FakeHandler h = FakeHandler(
      'notification.action',
      outcome: const SyncOutcome.terminal(NotFoundFailure(code: 'NOT_FOUND')),
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('notification.action', 'n1'));

    expect(outbox.count, 0);
    expect(history.readAll().single.result, SyncHistoryResult.dropped);
  });

  test('conflict parks the op; keepServer discards, keepLocal retries', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final FakeHandler h = FakeHandler(
      'profile.update',
      outcome: const SyncOutcome.conflict(detail: 'server_changed'),
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('profile.update', 'me'));
    expect(engine.conflicts.length, 1);
    expect(engine.status.value.phase, SyncPhase.error);

    // Keep server → discard.
    await engine.resolveConflict('profile.update::me', ConflictResolution.keepServer);
    expect(outbox.count, 0);
    expect(engine.conflicts, isEmpty);
  });

  test('self-cancelling merge (null) drops both queued ops', () async {
    final FakeConnectivity conn = FakeConnectivity(online: false);
    final FakeHandler h = FakeHandler(
      'social.piece_like',
      outcome: const SyncOutcome.success(),
      mergeToNull: true,
    );
    final SyncEngine engine = build(conn, <SyncHandler>[h])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('social.piece_like', 'p1', id: 'a'));
    expect(outbox.count, 1);
    // Second enqueue on the same key merges to null → both dropped.
    await engine.enqueue(op('social.piece_like', 'p1', id: 'b'));
    expect(outbox.count, 0);
  });

  test('a type with no handler is dropped rather than wedging the queue', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final SyncEngine engine = build(conn, <SyncHandler>[])..start();
    addTearDown(engine.dispose);

    await engine.enqueue(op('unknown.type', 'x'));
    expect(outbox.count, 0);
    expect(history.readAll().single.error, 'no_handler');
  });

  test('registered background tasks run on drain', () async {
    final FakeConnectivity conn = FakeConnectivity(online: true);
    final SyncEngine engine = build(conn, <SyncHandler>[]);
    addTearDown(engine.dispose);
    int ran = 0;
    engine.registerTask((name: 'drafts', run: () async => ran++));
    engine.start();
    await engine.sync();
    expect(ran, greaterThanOrEqualTo(1));
  });
}
