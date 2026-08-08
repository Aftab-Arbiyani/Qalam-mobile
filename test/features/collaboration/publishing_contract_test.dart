/// Regression guards for the publishing defects **P-1…P-8** (`docs/56` §2.2).
///
/// Pins the wire shape at the layer that knows it (the data source) plus the entities
/// either side, in the style of `invite_contract_test.dart`. Every assertion here is
/// against `publishing.controller.ts` / `publishing-request.dto.ts` /
/// `publishing-response.dto.ts`, not against the mobile abstraction.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/publishing_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/review_session.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_publication_state.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_snapshot_history.dart';

class _MockApiClient extends Mock implements ApiClient {}

/// The real `PieceResponseDto` — what publish / unpublish / schedule / visibility /
/// revert actually answer. Trimmed of `content`/`author`, which the entity ignores.
Map<String, dynamic> _pieceResponse() => <String, dynamic>{
  'id': '019fa830-4ca1-7598-9ba9-42aab0061e66',
  'title': 'The Lamplighter',
  'subtitle': null,
  'slug': 'the-lamplighter',
  'featuredQuote': null,
  'coverImageKey': null,
  'status': 'published',
  'visibility': 'public',
  'wordCount': 1840,
  'readingTimeSeconds': 552,
  'scheduledAt': null,
  'publishedAt': '2026-07-28T09:00:00.000Z',
  'archivedAt': null,
  'createdAt': '2026-07-01T09:00:00.000Z',
  'updatedAt': '2026-07-28T09:00:00.000Z',
};

/// The real `SnapshotDto`.
Map<String, dynamic> _snapshotResponse() => <String, dynamic>{
  'id': 'snap-1',
  'storyId': '019fa830-4ca1-7598-9ba9-42aab0061e66',
  'version': 3,
  'title': 'The Lamplighter',
  'content': <String, dynamic>{'type': 'doc'},
  'wordCount': 1840,
  'reason': 'manual',
  'createdById': 'u1',
  'createdAt': '2026-07-28T09:00:00.000Z',
};

/// The real `ReviewDto`.
Map<String, dynamic> _reviewResponse() => <String, dynamic>{
  'id': 'rev-1',
  'storyId': '019fa830-4ca1-7598-9ba9-42aab0061e66',
  'requestedById': 'u1',
  'state': 'changes_requested',
  'reviewerId': 'u2',
  'decision': 'request_changes',
  'notes': 'Tighten the second act.',
  'submittedAt': '2026-07-20T09:00:00.000Z',
  'decidedAt': '2026-07-21T09:00:00.000Z',
  'createdAt': '2026-07-20T09:00:00.000Z',
  'updatedAt': '2026-07-21T09:00:00.000Z',
};

void main() {
  setUpAll(() => registerFallbackValue(<String, Object?>{}));

  late _MockApiClient api;
  late PublishingRemoteDataSource remote;

  setUp(() {
    api = _MockApiClient();
    remote = PublishingRemoteDataSource(api);
  });

  group('publication actions decode the piece, not an event (P-1)', () {
    test('StoryPublicationState parses every PieceResponseDto field it uses', () {
      final StoryPublicationState state = StoryPublicationState.fromJson(
        _pieceResponse(),
      );

      expect(state.id, '019fa830-4ca1-7598-9ba9-42aab0061e66');
      expect(state.title, 'The Lamplighter');
      expect(state.status, 'published');
      expect(state.visibility, 'public');
      expect(state.slug, 'the-lamplighter');
      expect(state.wordCount, 1840);
      expect(state.publishedAt, isNotNull);
      expect(state.isPublished, isTrue);
      expect(state.isScheduled, isFalse);
    });

    test('a scheduled piece reads scheduledAt — not the old scheduledFor', () {
      final Map<String, dynamic> json = _pieceResponse()
        ..['status'] = 'scheduled'
        ..['publishedAt'] = null
        ..['scheduledAt'] = '2026-08-01T09:00:00.000Z';

      final StoryPublicationState state = StoryPublicationState.fromJson(json);

      expect(state.scheduledAt, DateTime.parse('2026-08-01T09:00:00.000Z'));
      expect(state.isScheduled, isTrue);
      expect(state.isPublished, isFalse);
    });

    test('publish sends NO body and decodes the piece', () async {
      when(
        () => api.post<StoryPublicationState>(
          any(),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => StoryPublicationState.fromJson(_pieceResponse()),
      );

      final StoryPublicationState state = await remote.publish(storyId: 's1');

      expect(state.status, 'published');
      // `publish` declares no @Body(); anything sent was silently discarded (P-8).
      verify(
        () => api.post<StoryPublicationState>(
          '/stories/s1/publish',
          decode: any(named: 'decode'),
        ),
      ).called(1);
    });

    test('revert decodes the piece, so its id is the piece id (P-1)', () async {
      when(
        () => api.post<StoryPublicationState>(
          any(),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => StoryPublicationState.fromJson(_pieceResponse()),
      );

      final StoryPublicationState state = await remote.revertToSnapshot(
        storyId: 's1',
        snapshotId: 'snap-1',
      );

      // Decoded as a StorySnapshot this id would have been used against
      // GET /snapshots/{id} and 404'd.
      expect(state.id, '019fa830-4ca1-7598-9ba9-42aab0061e66');
      verify(
        () => api.post<StoryPublicationState>(
          '/stories/s1/snapshots/snap-1/revert',
          decode: any(named: 'decode'),
        ),
      ).called(1);
    });
  });

  group('schedule body (P-2)', () {
    test('sends exactly {scheduledAt} — never scheduledFor or visibility', () async {
      when(
        () => api.post<StoryPublicationState>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => StoryPublicationState.fromJson(_pieceResponse()),
      );

      await remote.schedule(
        storyId: 's1',
        scheduledAt: DateTime.utc(2026, 8, 1, 9),
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<StoryPublicationState>(
                  '/stories/s1/schedule',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{'scheduledAt': '2026-08-01T09:00:00.000Z'});
      // The two keys that made every schedule fail validation.
      expect(body.containsKey('scheduledFor'), isFalse);
      expect(body.containsKey('visibility'), isFalse);
    });
  });

  group('visibility (P-3)', () {
    test('the mirror is exactly the server Visibility enum', () {
      // `packages/shared/src/enums.ts` — public | unlisted | private.
      expect(StoryVisibility.ordered, <String>['private', 'unlisted', 'public']);
      expect(StoryVisibility.ordered, isNot(contains('followers')));
    });

    test('changeVisibility sends {visibility}', () async {
      when(
        () => api.patch<StoryPublicationState>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => StoryPublicationState.fromJson(_pieceResponse()),
      );

      await remote.changeVisibility(
        storyId: 's1',
        visibility: StoryVisibility.unlisted,
      );

      final Map<String, Object?> body =
          verify(
                () => api.patch<StoryPublicationState>(
                  '/stories/s1/visibility',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{'visibility': 'unlisted'});
    });
  });

  group('review null-data path (P-4)', () {
    test('review() uses getOrNull and yields null for no session', () async {
      when(
        () => api.getOrNull<ReviewSession>(
          any(),
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => null);

      final ReviewSession? session = await remote.review('s1');

      // Pre-fix this path raised API_MALFORMED_RESPONSE, so the Review card
      // errored for every story that had never been submitted.
      expect(session, isNull);
      verify(
        () => api.getOrNull<ReviewSession>(
          '/stories/s1/review',
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('review() still decodes a real session', () async {
      when(
        () => api.getOrNull<ReviewSession>(
          any(),
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => ReviewSession.fromJson(_reviewResponse()));

      final ReviewSession? session = await remote.review('s1');

      expect(session, isNotNull);
      expect(session!.isChangesRequested, isTrue);
    });
  });

  group('request-changes body (P-5)', () {
    test('sends notes, not note', () async {
      when(
        () => api.post<ReviewSession>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer((_) async => ReviewSession.fromJson(_reviewResponse()));

      await remote.requestChanges(storyId: 's1', notes: 'Tighten the second act.');

      final Map<String, Object?> body =
          verify(
                () => api.post<ReviewSession>(
                  '/stories/s1/review/changes',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{'notes': 'Tighten the second act.'});
      expect(body.containsKey('note'), isFalse);
    });
  });

  group('ReviewSession mirrors ReviewDto (P-6)', () {
    test('reads requestedById / submittedAt / decision', () {
      final ReviewSession session = ReviewSession.fromJson(_reviewResponse());

      expect(session.requestedById, 'u1');
      expect(session.submittedAt, DateTime.parse('2026-07-20T09:00:00.000Z'));
      expect(session.decision, 'request_changes');
      expect(session.reviewerId, 'u2');
      expect(session.notes, 'Tighten the second act.');
      expect(session.state, ReviewState.changesRequested);
    });
  });

  group('StorySnapshot mirrors SnapshotDto (P-7)', () {
    test('reads version / title / reason / createdById', () {
      final StorySnapshot snapshot = StorySnapshot.fromJson(_snapshotResponse());

      expect(snapshot.version, 3);
      expect(snapshot.title, 'The Lamplighter');
      expect(snapshot.reason, 'manual');
      expect(snapshot.createdById, 'u1');
      expect(snapshot.wordCount, 1840);
      expect(snapshot.label, 'The Lamplighter');
    });

    test('falls back to a version label when the title is empty', () {
      final StorySnapshot snapshot = StorySnapshot.fromJson(
        _snapshotResponse()..['title'] = '',
      );

      expect(snapshot.label, 'Version 3');
    });

    /// B7 (`platfrom/docs/45` §4.12) changed this route's shape: it answers an OBJECT so
    /// the clamped list can carry the true total with it. Pinned at the data source, which
    /// is the layer that knows the wire — decoding it as a list again would yield an empty
    /// history and no count, the same class as P-1/P-7.
    test('snapshots reads the history OBJECT, not a bare list (B7)', () async {
      when(
        () => api.get<StorySnapshotHistory>(
          any(),
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => StorySnapshotHistory.fromJson(<String, dynamic>{
          'items': <Object?>[_snapshotResponse()],
          'total': 32,
          'visible': 1,
          'hidden': 31,
          'limit': 5,
          'unlimited': false,
        }),
      );

      final StorySnapshotHistory history = await remote.snapshots('s1');

      verify(
        () => api.get<StorySnapshotHistory>(
          '/stories/s1/snapshots',
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      expect(history.items, hasLength(1));
      expect(history.total, 32);
      expect(history.isLimited, isTrue);
    });

    test('createSnapshot sends no body — the handler has no @Body() (P-7/P-8)', () async {
      when(
        () => api.post<StorySnapshot>(any(), decode: any(named: 'decode')),
      ).thenAnswer((_) async => StorySnapshot.fromJson(_snapshotResponse()));

      await remote.createSnapshot(storyId: 's1');

      verify(
        () => api.post<StorySnapshot>(
          '/stories/s1/snapshots',
          decode: any(named: 'decode'),
        ),
      ).called(1);
    });
  });

  group('bodies the server never read are gone (P-8)', () {
    test('requestReview and approveReview send no body', () async {
      when(
        () => api.post<ReviewSession>(any(), decode: any(named: 'decode')),
      ).thenAnswer((_) async => ReviewSession.fromJson(_reviewResponse()));

      await remote.requestReview(storyId: 's1');
      await remote.approveReview(storyId: 's1');

      verify(
        () => api.post<ReviewSession>(
          '/stories/s1/review',
          decode: any(named: 'decode'),
        ),
      ).called(1);
      verify(
        () => api.post<ReviewSession>(
          '/stories/s1/review/approve',
          decode: any(named: 'decode'),
        ),
      ).called(1);
    });

    test('unpublish sends no body', () async {
      when(
        () => api.post<StoryPublicationState>(
          any(),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => StoryPublicationState.fromJson(_pieceResponse()),
      );

      await remote.unpublish(storyId: 's1');

      verify(
        () => api.post<StoryPublicationState>(
          '/stories/s1/unpublish',
          decode: any(named: 'decode'),
        ),
      ).called(1);
    });
  });
}
