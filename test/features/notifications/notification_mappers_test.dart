import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/notifications/data/mappers/notification_mappers.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

void main() {
  group('notificationFromJson', () {
    test('maps a full like notification with actor + piece payload', () {
      final n = notificationFromJson(<String, dynamic>{
        'id': 'n1',
        'type': 'like',
        'status': 'unread',
        'actor': <String, dynamic>{
          'username': 'ali',
          'penName': 'Ali',
          'avatarKey': 'a/k.webp',
        },
        'entityType': 'piece',
        'entityId': 'p1',
        'data': <String, dynamic>{
          'piece': <String, dynamic>{'slug': 'my-piece', 'title': 'My Piece'},
        },
        'readAt': null,
        'createdAt': '2026-07-16T10:00:00.000Z',
      });

      expect(n.id, 'n1');
      expect(n.type, NotificationType.like);
      expect(n.status, NotificationStatus.unread);
      expect(n.isUnread, isTrue);
      expect(n.actor?.username, 'ali');
      expect(n.actor?.avatarKey, 'a/k.webp');
      expect(n.entityType, NotificationEntityType.piece);
      expect(n.entityId, 'p1');
      expect(n.payload.pieceSlug, 'my-piece');
      expect(n.payload.pieceTitle, 'My Piece');
      expect(n.createdAt.isUtc, isTrue);
    });

    test('extracts comment payload (id + excerpt)', () {
      final n = notificationFromJson(<String, dynamic>{
        'id': 'n2',
        'type': 'comment',
        'status': 'read',
        'entityType': 'comment',
        'entityId': 'c1',
        'data': <String, dynamic>{
          'piece': <String, dynamic>{'slug': 'p', 'title': 'P'},
          'comment': <String, dynamic>{'id': 'c1', 'excerpt': 'nice work'},
        },
        'readAt': '2026-07-16T11:00:00.000Z',
        'createdAt': '2026-07-16T10:00:00.000Z',
      });
      expect(n.type, NotificationType.comment);
      expect(n.status, NotificationStatus.read);
      expect(n.payload.commentId, 'c1');
      expect(n.payload.commentExcerpt, 'nice work');
      expect(n.readAt, isNotNull);
    });

    test(
      'unknown type + entityType fall back to unknown (additive tolerance)',
      () {
        final n = notificationFromJson(<String, dynamic>{
          'id': 'n3',
          'type': 'brand_new_kind',
          'entityType': 'widget',
          'createdAt': '2026-07-16T10:00:00.000Z',
        });
        expect(n.type, NotificationType.unknown);
        expect(n.entityType, NotificationEntityType.unknown);
      },
    );

    test('tolerates missing/garbage fields without throwing', () {
      final n = notificationFromJson(<String, dynamic>{'id': 'n4'});
      expect(n.id, 'n4');
      expect(n.actor, isNull);
      expect(n.payload.pieceSlug, isNull);
      // createdAt falls back to epoch rather than throwing.
      expect(n.createdAt, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
    });

    test('falls back to data.actor when top-level actor is absent', () {
      final n = notificationFromJson(<String, dynamic>{
        'id': 'n5',
        'type': 'follow',
        'data': <String, dynamic>{
          'actor': <String, dynamic>{'username': 'sara'},
        },
        'createdAt': '2026-07-16T10:00:00.000Z',
      });
      expect(n.actor?.username, 'sara');
    });

    test('system notification lifts title/message/link from data', () {
      final n = notificationFromJson(<String, dynamic>{
        'id': 'n6',
        'type': 'system',
        'entityType': 'system',
        'data': <String, dynamic>{
          'title': 'Scheduled maintenance',
          'message': 'Back at 9pm',
          'link': '/settings',
        },
        'createdAt': '2026-07-16T10:00:00.000Z',
      });
      expect(n.payload.systemTitle, 'Scheduled maintenance');
      expect(n.payload.systemMessage, 'Back at 9pm');
      expect(n.payload.systemLink, '/settings');
    });

    test('round-trips through the cache codec (fromJson∘toJson)', () {
      final original = notificationFromJson(<String, dynamic>{
        'id': 'n7',
        'type': 'clap',
        'status': 'archived',
        'entityType': 'piece',
        'entityId': 'p9',
        'data': <String, dynamic>{
          'piece': <String, dynamic>{'slug': 's', 'title': 't'},
        },
        'archivedAt': '2026-07-16T12:00:00.000Z',
        'createdAt': '2026-07-16T10:00:00.000Z',
      });
      final roundTripped = AppNotification.fromJson(original.toJson());
      expect(roundTripped.type, NotificationType.clap);
      expect(roundTripped.status, NotificationStatus.archived);
      expect(roundTripped.entityId, 'p9');
      expect(roundTripped.payload.pieceSlug, 's');
    });
  });

  group('notificationPreferencesFromJson', () {
    test('maps the seven categories, defaulting missing to true', () {
      final prefs = notificationPreferencesFromJson(<String, dynamic>{
        'follow': false,
        'reaction': false,
      });
      expect(prefs.follow, isFalse);
      expect(prefs.reaction, isFalse);
      expect(prefs.comment, isTrue); // missing → default true
      expect(prefs.system, isTrue);
    });
  });

  group('unreadCountFromJson', () {
    test('maps count + capped', () {
      final c = unreadCountFromJson(<String, dynamic>{
        'count': 12,
        'capped': true,
      });
      expect(c.count, 12);
      expect(c.capped, isTrue);
      expect(c.hasUnread, isTrue);
    });

    test('defaults to zero on empty', () {
      final c = unreadCountFromJson(<String, dynamic>{});
      expect(c.count, 0);
      expect(c.hasUnread, isFalse);
    });
  });
}
