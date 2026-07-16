import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/logging/app_logger.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/social/data/social_outbox_store.dart';
import 'package:qalam_mobile/shared/social/data/social_sync_engine.dart';
import 'package:qalam_mobile/shared/social/domain/engagement_repository.dart';
import 'package:qalam_mobile/shared/social/domain/value_objects/queued_social_action.dart';

/// A connectivity service whose online state + reconnect stream we drive.
class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity({required bool online}) : _online = online;
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

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

/// A configurable engagement repository that records like/unlike calls.
class _FakeEngagement implements EngagementRepository {
  Result<LikeOutcome> likeResult = const Ok<LikeOutcome>((liked: true, totalLikes: 1));
  int likeCalls = 0;

  @override
  Future<Result<LikeOutcome>> like(String pieceId) async {
    likeCalls++;
    return likeResult;
  }

  @override
  Future<Result<Unit>> unlike(String pieceId) async => const Ok<Unit>(unit);
  @override
  Future<Result<bool>> bookmark(String pieceId) async => const Ok<bool>(true);
  @override
  Future<Result<Unit>> unbookmark(String pieceId) async => const Ok<Unit>(unit);
  @override
  Future<Result<int>> share(String pieceId, ShareChannel channel) async => const Ok<int>(1);
  @override
  Future<Result<FollowStatus>> follow(String userId) async =>
      const Ok<FollowStatus>(FollowStatus.accepted);
  @override
  Future<Result<Unit>> unfollow(String userId) async => const Ok<Unit>(unit);
  @override
  Future<Result<Unit>> report({
    required ReportEntityType entityType,
    required String entityId,
    required ReportReason reason,
    String? description,
  }) async => const Ok<Unit>(unit);
}

QueuedSocialAction _like(String id) => QueuedSocialAction(
  category: SocialCategory.pieceLike,
  targetId: id,
  desired: true,
  createdAt: DateTime.utc(2026),
);

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late SocialOutboxStore store;
  late _FakeEngagement engagement;
  final AppLogger logger = AppLogger(flavor: AppFlavor.development);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qalam_sync');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('prefs_${dir.path.hashCode}');
    store = SocialOutboxStore(box);
    engagement = _FakeEngagement();
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('offline enqueue stores without calling the server', () async {
    final conn = _FakeConnectivity(online: false);
    final engine = SocialSyncEngine(
      engagement: engagement,
      store: store,
      connectivity: conn,
      logger: logger,
    );
    await engine.enqueue(_like('p1'));
    expect(store.count, 1);
    expect(engagement.likeCalls, 0);
    engine.dispose();
  });

  test('online enqueue flushes immediately and clears the entry', () async {
    final conn = _FakeConnectivity(online: true);
    final engine = SocialSyncEngine(
      engagement: engagement,
      store: store,
      connectivity: conn,
      logger: logger,
    );
    await engine.enqueue(_like('p1'));
    expect(engagement.likeCalls, 1);
    expect(store.count, 0);
    engine.dispose();
  });

  test('reconnect flushes the queued action', () async {
    final conn = _FakeConnectivity(online: false);
    final engine = SocialSyncEngine(
      engagement: engagement,
      store: store,
      connectivity: conn,
      logger: logger,
    )..start();
    await engine.enqueue(_like('p1'));
    expect(store.count, 1);

    conn.goOnline();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(engagement.likeCalls, 1);
    expect(store.count, 0);
    engine.dispose();
  });

  test('a transient failure keeps the action queued for retry', () async {
    final conn = _FakeConnectivity(online: true);
    engagement.likeResult = const Err<LikeOutcome>(
      NetworkFailure(code: 'API_NETWORK_ERROR'),
    );
    final engine = SocialSyncEngine(
      engagement: engagement,
      store: store,
      connectivity: conn,
      logger: logger,
    );
    await engine.enqueue(_like('p1'));
    expect(store.count, 1); // still queued
    engine.dispose();
  });

  test('a terminal failure drops the action', () async {
    final conn = _FakeConnectivity(online: true);
    engagement.likeResult = const Err<LikeOutcome>(
      NotFoundFailure(code: 'PIECE_NOT_FOUND'),
    );
    final engine = SocialSyncEngine(
      engagement: engagement,
      store: store,
      connectivity: conn,
      logger: logger,
    );
    await engine.enqueue(_like('p1'));
    expect(store.count, 0); // dropped
    engine.dispose();
  });
}
