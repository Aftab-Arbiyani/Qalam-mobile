/// The social module's composition root (docs/40 §9). Binds every social domain
/// repository to its implementation, and exposes the offline outbox + sync engine.
/// Cross-cutting and shared: the reading surface, the profile surface, and the
/// social feature all depend on THESE providers (docs/40 §7.3) — no feature owns a
/// duplicate social repository.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import 'data/collection_remote_data_source.dart';
import 'data/collection_repository_impl.dart';
import 'data/comment_remote_data_source.dart';
import 'data/comment_repository_impl.dart';
import 'data/engagement_remote_data_source.dart';
import 'data/engagement_repository_impl.dart';
import 'data/follow_remote_data_source.dart';
import 'data/follow_repository_impl.dart';
import 'data/response_remote_data_source.dart';
import 'data/response_repository_impl.dart';
import 'domain/collection_repository.dart';
import 'domain/comment_repository.dart';
import 'domain/engagement_repository.dart';
import 'domain/follow_repository.dart';
import 'domain/response_repository.dart';

part 'social_providers.g.dart';

// ── Engagement (reactions + follow action + report) ──────────────────────────

@Riverpod(keepAlive: true)
EngagementRemoteDataSource engagementRemoteDataSource(Ref ref) =>
    EngagementRemoteDataSource(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
EngagementRepository engagementRepository(Ref ref) =>
    EngagementRepositoryImpl(ref.watch(engagementRemoteDataSourceProvider));

// ── Follow graph (lists + requests) ──────────────────────────────────────────

@riverpod
FollowRemoteDataSource followRemoteDataSource(Ref ref) =>
    FollowRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
FollowRepository followRepository(Ref ref) => FollowRepositoryImpl(
  ref.watch(followRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
);

// ── Comments ─────────────────────────────────────────────────────────────────

@riverpod
CommentRemoteDataSource commentRemoteDataSource(Ref ref) =>
    CommentRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
CommentRepository commentRepository(Ref ref) => CommentRepositoryImpl(
  ref.watch(commentRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
);

// ── Responses ────────────────────────────────────────────────────────────────

@riverpod
ResponseRemoteDataSource responseRemoteDataSource(Ref ref) =>
    ResponseRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
ResponseRepository responseRepository(Ref ref) => ResponseRepositoryImpl(
  ref.watch(responseRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
);

// ── Collections ──────────────────────────────────────────────────────────────

@riverpod
CollectionRemoteDataSource collectionRemoteDataSource(Ref ref) =>
    CollectionRemoteDataSource(ref.watch(apiClientProvider));

@riverpod
CollectionRepository collectionRepository(Ref ref) => CollectionRepositoryImpl(
  ref.watch(collectionRemoteDataSourceProvider),
  ref.watch(cacheListDataSourceProvider),
  ref.watch(cacheStoreProvider),
);

// Offline queued social actions (likes / bookmarks / follows) and queued comments
// now flow through the single unified `SyncEngine` (see `core/sync` +
// `app/sync_bootstrap.dart`) — there is no feature-specific social outbox/engine.
