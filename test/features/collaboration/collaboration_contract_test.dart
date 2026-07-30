/// Regression guards for the collaboration defects **C-3…C-12** and the trust
/// defects **T-1/T-2** (`docs/56` §2.1, §2.3).
///
/// Same discipline as `invite_contract_test.dart`: assert the wire shape at the data
/// source and the entities either side, never the mobile abstraction. Every payload
/// below is the real DTO from `collaboration-response.dto.ts` /
/// `trust-response.dto.ts`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/block_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_activity_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_comment.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/edit_suggestion.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/story_member.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/text_anchor.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';

class _MockApiClient extends Mock implements ApiClient {}

/// The real `SuggestionDto`.
Map<String, dynamic> _suggestionDto() => <String, dynamic>{
  'id': 'sug-1',
  'storyId': 's1',
  'authorId': '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe',
  'anchor': <String, dynamic>{'from': 120, 'to': 148},
  'originalText': 'the old sentence',
  'suggestedText': 'the better sentence',
  'status': 'pending',
  'resolvedById': null,
  'resolvedAt': null,
  'createdAt': '2026-07-28T09:00:00.000Z',
};

/// The real `CommentDto` for an inline comment.
Map<String, dynamic> _commentDto() => <String, dynamic>{
  'id': 'c-1',
  'storyId': 's1',
  'authorId': '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe',
  'parentId': null,
  'kind': 'inline',
  'anchor': <String, dynamic>{'from': 10, 'to': 24, 'quote': 'a lamplit street'},
  'body': 'Lovely image.',
  'status': 'open',
  'resolvedById': null,
  'mentions': <dynamic>['019f0000-0000-7000-8000-000000000001'],
  'createdAt': '2026-07-28T09:00:00.000Z',
  'updatedAt': '2026-07-28T09:00:00.000Z',
};

void main() {
  setUpAll(() => registerFallbackValue(<String, Object?>{}));

  late _MockApiClient api;
  late CollaborationRemoteDataSource remote;

  setUp(() {
    api = _MockApiClient();
    remote = CollaborationRemoteDataSource(api);
  });

  group('suggestion create body (C-3)', () {
    test('sends {anchor:{from,to}, originalText, suggestedText} exactly', () async {
      when(
        () => api.post<EditSuggestion>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer((_) async => EditSuggestion.fromJson(_suggestionDto()));

      await remote.addSuggestion(
        storyId: 's1',
        anchor: const TextAnchor(from: 120, to: 148),
        originalText: 'the old sentence',
        suggestedText: 'the better sentence',
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<EditSuggestion>(
                  '/stories/s1/suggestions',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{
        'anchor': <String, Object?>{'from': 120, 'to': 148},
        'originalText': 'the old sentence',
        'suggestedText': 'the better sentence',
      });
      // The required field that was always missing, and the two undeclared keys.
      expect(body.containsKey('anchor'), isTrue);
      expect(body.containsKey('blockId'), isFalse);
      expect(body.containsKey('rationale'), isFalse);
    });

    test('the suggestion anchor body carries no quote key', () {
      // `SuggestionAnchorDto` declares only from/to — a quote would be rejected.
      const TextAnchor anchor = TextAnchor(from: 1, to: 2, quote: 'ignored');
      expect(anchor.toSuggestionJson(), <String, Object?>{'from': 1, 'to': 2});
    });
  });

  group('EditSuggestion mirrors SuggestionDto (C-4)', () {
    test('reads the anchor and resolvedById', () {
      final EditSuggestion s = EditSuggestion.fromJson(_suggestionDto());

      expect(s.anchor, isNotNull);
      expect(s.anchor!.from, 120);
      expect(s.anchor!.to, 148);
      expect(s.anchor!.length, 28);
      expect(s.authorId, '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe');
      expect(s.isPending, isTrue);
    });

    test('resolvedById is read from the real key', () {
      final EditSuggestion s = EditSuggestion.fromJson(
        _suggestionDto()
          ..['status'] = 'accepted'
          ..['resolvedById'] = 'u-owner'
          ..['resolvedAt'] = '2026-07-28T10:00:00.000Z',
      );

      // The old entity read `resolvedBy`, so this was always null.
      expect(s.resolvedById, 'u-owner');
      expect(s.resolvedAt, isNotNull);
      expect(s.isAccepted, isTrue);
    });
  });

  group('comment threads (C-5)', () {
    test('CommentThread decodes {comment, replies}', () {
      final CommentThread thread = CommentThread.fromJson(<String, dynamic>{
        'comment': _commentDto(),
        'replies': <dynamic>[
          _commentDto()
            ..['id'] = 'c-2'
            ..['parentId'] = 'c-1'
            ..['kind'] = 'general'
            ..['anchor'] = null,
        ],
      });

      expect(thread.comment.id, 'c-1');
      expect(thread.replyCount, 1);
      expect(thread.replies.single.isReply, isTrue);
      expect(thread.replies.single.parentId, 'c-1');
    });

    test('commentThread() calls /comments/{id}/thread', () async {
      when(
        () => api.get<CommentThread>(
          any(),
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => CommentThread.fromJson(<String, dynamic>{
          'comment': _commentDto(),
          'replies': <dynamic>[],
        }),
      );

      await remote.commentThread('c-1');

      verify(
        () => api.get<CommentThread>(
          '/comments/c-1/thread',
          decode: any(named: 'decode'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('a CommentDto carries no replies — the entity must not invent them', () {
      // Guards the shape rather than a field: if someone re-adds a `replies`
      // getter fed from the list payload, this documents why that is wrong.
      expect(_commentDto().containsKey('replies'), isFalse);
    });
  });

  group('comment anchor + body (C-6, C-7)', () {
    test('the comment anchor body is {from,to,quote}', () {
      const TextAnchor anchor = TextAnchor(from: 10, to: 24, quote: 'a street');
      expect(anchor.toCommentJson(), <String, Object?>{
        'from': 10,
        'to': 24,
        'quote': 'a street',
      });
    });

    test('addComment sends no parentId and the right anchor keys', () async {
      when(
        () => api.post<CollaborationComment>(
          any(),
          body: any(named: 'body'),
          decode: any(named: 'decode'),
        ),
      ).thenAnswer(
        (_) async => CollaborationComment.fromJson(_commentDto()),
      );

      await remote.addComment(
        storyId: 's1',
        body: 'Lovely image.',
        kind: CommentKind.inline,
        anchor: const TextAnchor(from: 10, to: 24, quote: 'a lamplit street'),
      );

      final Map<String, Object?> body =
          verify(
                () => api.post<CollaborationComment>(
                  '/stories/s1/comments',
                  body: captureAny(named: 'body'),
                  decode: any(named: 'decode'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body['kind'], 'inline');
      expect(body['anchor'], <String, Object?>{
        'from': 10,
        'to': 24,
        'quote': 'a lamplit street',
      });
      // The keys that would have failed forbidNonWhitelisted.
      expect(body.containsKey('parentId'), isFalse);
      final Map<String, Object?> anchor = body['anchor']! as Map<String, Object?>;
      expect(anchor.containsKey('blockId'), isFalse);
      expect(anchor.containsKey('start'), isFalse);
      expect(anchor.containsKey('end'), isFalse);
    });

    test('the comment entity reads the anchor range, not just the quote', () {
      final CollaborationComment c = CollaborationComment.fromJson(_commentDto());

      expect(c.anchor, isNotNull);
      expect(c.anchor!.from, 10);
      expect(c.anchor!.to, 24);
      expect(c.anchor!.quote, 'a lamplit street');
      expect(c.isInline, isTrue);
      expect(c.mentions, hasLength(1));
    });

    test('an anchor missing from/to decodes to null, not a zero range', () {
      final CollaborationComment c = CollaborationComment.fromJson(
        _commentDto()..['anchor'] = <String, dynamic>{'quote': 'orphan'},
      );
      expect(c.anchor, isNull);
    });
  });

  group('presence heartbeat body (C-8)', () {
    test('sends only {state}', () async {
      when(
        () => api.postVoid(any(), body: any(named: 'body')),
      ).thenAnswer((_) async {});

      await remote.heartbeat(storyId: 's1', state: PresenceState.typing);

      final Map<String, Object?> body =
          verify(
                () => api.postVoid(
                  '/stories/s1/presence',
                  body: captureAny(named: 'body'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(body, <String, Object?>{'state': 'typing'});
      expect(body.containsKey('blockId'), isFalse);
    });
  });

  group('StoryMember mirrors MemberDto (C-9)', () {
    test('reads invitedById and tolerates the owner null joinedAt', () {
      final StoryMember owner = StoryMember.fromJson(<String, dynamic>{
        'userId': '019f9247-c8a6-759f-afa2-cb4ca5fe6ebe',
        'role': 'owner',
        'invitedById': null,
        'joinedAt': null,
      });

      expect(owner.isOwner, isTrue);
      expect(owner.joinedAt, isNull);
      expect(owner.invitedById, isNull);
      // Honest about being an id — the wire sends no name.
      expect(owner.label, '019f…6ebe');
    });

    test('reads invitedById from the real key, not invitedBy', () {
      final StoryMember member = StoryMember.fromJson(<String, dynamic>{
        'userId': 'u2',
        'role': 'editor',
        'invitedById': 'u1',
        'joinedAt': '2026-07-28T09:00:00.000Z',
      });

      expect(member.invitedById, 'u1');
      expect(member.joinedAt, isNotNull);
    });
  });

  group('cursor pagination (C-10)', () {
    test('comments() forwards cursor/limit/status and returns a page', () async {
      when(
        () => api.getPage<CollaborationComment>(
          any(),
          query: any(named: 'query'),
          decodeItem: any(named: 'decodeItem'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => CursorPage<CollaborationComment>(
          items: <CollaborationComment>[
            CollaborationComment.fromJson(_commentDto()),
          ],
          meta: const CursorMeta(nextCursor: 'abc', hasMore: true),
        ),
      );

      final CursorPage<CollaborationComment> page = await remote.comments(
        's1',
        cursor: 'prev',
        limit: 50,
        status: CommentStatus.open,
      );

      expect(page.items, hasLength(1));
      expect(page.meta.hasMore, isTrue);
      expect(page.meta.nextCursor, 'abc');

      final Map<String, Object?> query =
          verify(
                () => api.getPage<CollaborationComment>(
                  '/stories/s1/comments',
                  query: captureAny(named: 'query'),
                  decodeItem: any(named: 'decodeItem'),
                  cancelToken: any(named: 'cancelToken'),
                ),
              ).captured.single
              as Map<String, Object?>;

      expect(query, <String, Object?>{
        'cursor': 'prev',
        'limit': 50,
        'status': 'open',
      });
    });
  });

  group('ActivityDto (C-11)', () {
    test('reads actorId + snake_case type; invents no summary', () {
      final CollaborationActivityEntry e =
          CollaborationActivityEntry.fromJson(<String, dynamic>{
            'id': 'a1',
            'storyId': 's1',
            'actorId': 'u1',
            'type': 'suggestion_accepted',
            'metadata': <String, dynamic>{'suggestionId': 'sug-1'},
            'createdAt': '2026-07-28T09:00:00.000Z',
          });

      expect(e.actorId, 'u1');
      // The real catalogue is snake_case (`CollaborationActivity`).
      expect(e.type, 'suggestion_accepted');
      expect(e.metadata['suggestionId'], 'sug-1');
    });
  });

  group('BlockDto (T-1)', () {
    test('blockedId is the user, and is not confused with the row id', () {
      final BlockEntry entry = BlockEntry.fromJson(<String, dynamic>{
        'id': '019fb000-0000-7000-8000-00000000000b',
        'blockerId': '019fa000-0000-7000-8000-00000000000a',
        'blockedId': '019fc000-0000-7000-8000-00000000000c',
        'kind': 'mute',
        'createdAt': '2026-07-28T09:00:00.000Z',
      });

      // The bug: `userId` fell back to `json['id']`, the block ROW, so unblocking
      // targeted /users/{blockRowId}/block and 404'd.
      expect(entry.blockedId, '019fc000-0000-7000-8000-00000000000c');
      expect(entry.id, '019fb000-0000-7000-8000-00000000000b');
      expect(entry.blockedId, isNot(entry.id));
      expect(entry.isMute, isTrue);
    });
  });

  group('RestrictionDto (T-2)', () {
    test('derives active from liftedAt and reads scope', () {
      final UserRestriction inForce = UserRestriction.fromJson(<String, dynamic>{
        'id': 'r1',
        'userId': 'u1',
        'type': 'read_only',
        'scope': 'publishing',
        'reason': 'Repeated guideline violations',
        'issuedById': 'mod1',
        'expiresAt': null,
        'liftedAt': null,
        'createdAt': '2026-07-28T09:00:00.000Z',
      });

      expect(inForce.scope, RestrictionScope.publishing);
      expect(inForce.active, isTrue);
      expect(inForce.isPermanent, isTrue);
    });

    test('a lifted restriction is not active', () {
      final UserRestriction lifted = UserRestriction.fromJson(<String, dynamic>{
        'id': 'r2',
        'type': 'muted',
        'scope': 'comments',
        'reason': 'x',
        'liftedAt': '2026-07-28T10:00:00.000Z',
      });

      // The old entity defaulted `active: true` off a key the wire never sends,
      // so a lifted restriction would still have shown as in force.
      expect(lifted.active, isFalse);
    });

    test('TrustSummary filters activeRestrictions on the derived flag', () {
      final TrustSummary summary = TrustSummary.fromJson(<String, dynamic>{
        'score': 20,
        'level': 'basic',
        'status': 'read_only',
        'activeStrikeWeight': 3,
        'restrictions': <dynamic>[
          <String, dynamic>{
            'id': 'r1',
            'type': 'read_only',
            'scope': 'global',
            'reason': 'a',
            'liftedAt': null,
          },
          <String, dynamic>{
            'id': 'r2',
            'type': 'muted',
            'scope': 'comments',
            'reason': 'b',
            'liftedAt': '2026-07-28T10:00:00.000Z',
          },
        ],
      });

      expect(summary.restrictions, hasLength(2));
      expect(summary.activeRestrictions, hasLength(1));
      expect(summary.isReadOnly, isTrue);
      // r2 is lifted, so the account is not muted.
      expect(summary.isMuted, isFalse);
    });
  });
}
